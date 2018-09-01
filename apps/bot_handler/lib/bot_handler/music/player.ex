defmodule Bot.Handler.Music.Player do
  use GenServer

  require Logger

  alias Bot.Handler.Lavalink

  import Bot.Handler.Util

  @registry Bot.Handler.Music.Registry

  def start_link({guild_id, _channel_id} = state) do
    name = {:via, Registry, {@registry, guild_id}}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @spec ensure_started(state :: {Crux.Rest.snowflake(), Crux.Rest.snowflake()}) :: pid()
  def ensure_started({guild_id, _channel_id} = state) do
    with {:ok, pid} <- lookup(guild_id) do
      pid
    else
      _ ->
        Bot.Handler.Music.Supervisor.start_child(state)
        ensure_started(state)
    end
  end

  @spec lookup(guild_id :: Crux.Rest.snowflake()) :: {:ok, pid()} | :error
  def lookup(guild_id) do
    with [{pid, _other}] <- Registry.lookup(@registry, guild_id),
         true <- Process.alive?(pid) do
      {:ok, pid}
    else
      _ ->
        :error
    end
  end

  @spec queue(track :: String.t() | [String.t()], id :: Crux.Rest.snowflake()) :: boolean() | nil
  def queue(track, id) do
    with {:ok, pid} <- lookup(id), do: GenServer.call(pid, {:queue, track})
  end

  @spec command(Crux.Rest.snowflake(), term()) :: term() | String.t()
  def command(id, command) do
    with {:ok, pid} <- lookup(id) do
      GenServer.call(pid, command)
    else
      :error ->
        "I am currently not playing anything here."
    end
  end

  def init({guild_id, channel_id}) do
    state = %{
      message: nil,
      guild_id: guild_id,
      # text channel
      channel_id: channel_id,
      queue: :queue.new(),
      loop: false,
      position: 0,
      paused: false
    }

    {:ok, state}
  end

  def handle_cast(
        {:dispatch, %{"op" => "event", "reason" => reason, "type" => "TrackEndEvent"}},
        state
      ) do
    state =
      state
      |> Map.put(:position, 0)
      |> Map.put(:paused, false)

    if state.message, do: rest(:delete_message, [state.message])

    state =
      if state.loop and reason not in ["REPLACED", "STOPPED"] do
        Map.update!(state, :queue, fn queue ->
          {:value, track} = :queue.peek(queue)
          :queue.in(track, queue)
        end)
      else
        state
      end

    if reason == "REPLACED" do
      {:noreply, state}
    else
      case play_next(state) do
        {:ok, state} ->
          {:noreply, state}

        {:error, _reason, state} ->
          {:stop, :normal, state}
      end
    end
  end

  def handle_cast(
        {:dispatch, %{"op" => "playerUpdate", "state" => %{"position" => position}}},
        state
      ) do
    {:noreply, Map.put(state, :position, position)}
  end

  def handle_cast({:dispatch, event}, state) do
    IO.inspect(event, label: "Other event")
    {:noreply, state}
  end

  def handle_call(
        {:queue, [track | _tracks] = tracks},
        _from,
        %{queue: queue, guild_id: guild_id} = state
      )
      when is_list(tracks) do
    should_start = :queue.is_empty(queue)
    queue = Enum.reduce(tracks, queue, &:queue.in/2)

    state =
      if should_start do
        Lavalink.Payload.volume(50, guild_id)
        |> Lavalink.Connection.send()

        play(track, state)
      else
        state
      end

    {:reply, should_start, Map.put(state, :queue, queue)}
  end

  def handle_call(:queue, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:loop, new_loop_state}, _from, state) do
    state =
      unless new_loop_state == :show,
        do: Map.put(state, :loop, new_loop_state),
        else: state

    {:reply, loop_state(state), state}
  end

  def handle_call(pause_or_resume, _from, %{guild_id: guild_id} = state)
      when pause_or_resume in [:pause, :resume] do
    pause = pause_or_resume == :pause

    Lavalink.Payload.pause(pause, guild_id)
    |> Lavalink.Connection.send()

    res =
      cond do
        pause && state.paused ->
          "The player is already paused."

        pause && !state.paused ->
          "Paused the player."

        pause_or_resume == :resume && state.paused ->
          "Resume the player."

        pause && state.paused ->
          "The player is already playing."
      end

    {:reply, res, Map.put(state, :paused, pause)}
  end

  def handle_call(:skip, _from, %{queue: queue, guild_id: guild_id} = state) do
    res =
      case :queue.peek(queue) do
        {:value, {_author, current}} ->
          time =
            current.info.length
            |> Bot.Handler.Music.Util.format_milliseconds()

          "You just skipped `#{current.info.title}` (`#{time}`), such a shame"

        :empty ->
          "The queue looks empty to me"
      end

    Lavalink.Payload.stop(guild_id)
    |> Lavalink.Connection.send()

    {:reply, res, state}
  end

  def handle_call(:stop, _from, %{guild_id: guild_id, queue: queue} = state) do
    first = :queue.get(queue)

    Lavalink.Payload.stop(guild_id)
    |> Lavalink.Connection.send()

    queue = :queue.in(first, :queue.new())

    {:reply, "Congratulations, you just killed the party 🎉", Map.put(state, :queue, queue)}
  end

  def handle_call(:shuffle, _from, %{queue: queue} = state) do
    [first | rest] = :queue.to_list(queue)
    rest = Enum.shuffle(rest)
    queue = :queue.from_list([first | rest])

    {:reply, "Shuffled playlist", Map.put(state, :queue, queue)}
  end

  @spec play_next(state :: map()) :: {:ok, map()} | {:error, :empty | :end, map()}
  defp play_next(%{queue: queue, guild_id: guild_id} = state) do
    with false <- :queue.is_empty(queue),
         queue <- :queue.drop(queue),
         {:value, next} <- :queue.peek(queue) do
      state = play(next, state)

      {:ok, Map.put(state, :queue, queue)}
    else
      true ->
        gateway(Bot.Gateway, :voice_state_update, [guild_id])

        {:error, :empty, state}

      :empty ->
        gateway(Bot.Gateway, :voice_state_update, [guild_id])

        {:error, :end, state}
    end
  end

  defp play(
         {author, %{track: track, info: info}},
         %{guild_id: guild_id, channel_id: channel_id} = state
       ) do
    {:ok, message} =
      rest(:create_message, [
        channel_id,
        [embed: Bot.Handler.Music.Util.build_embed(info, author, "play")]
      ])

    Lavalink.Payload.play(track, guild_id)
    |> Lavalink.Connection.send()

    Map.put(state, :message, message)
  end

  defp loop_state(%{loop: true}), do: "Loop is enabled."
  defp loop_state(%{loop: false}), do: "Loop is disabled."
end
