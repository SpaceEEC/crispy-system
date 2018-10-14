defmodule Bot.Lavalink.Player do
  @moduledoc false

  @enforce_keys [:guild_id, :channel_id]
  defstruct message: nil,
            guild_id: nil,
            # text channel
            channel_id: nil,
            queue: :queue.new(),
            loop: false,
            position: 0,
            paused: false

  @type t :: %{
          message: nil | Crux.Structs.Message.t(),
          guild_id: Crux.Rest.snowflake(),
          channel_id: Crux.Rest.snowflake(),
          queue: :queue.queue(),
          loop: boolean(),
          position: integer(),
          paused: boolean()
        }

  use GenServer

  require Logger

  alias Bot.Handler.Locale
  alias Bot.Handler.Mutil, as: Util
  alias Bot.Lavalink.{Connection, Payload, Player}

  import Bot.Handler.Rpc

  @registry Bot.Lavalink.Player.Registry

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
        Player.Supervisor.start_child(state)
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
        :LOC_MUSIC_NOT_PLAYING_HERE
    end
  end

  def init({guild_id, channel_id}) do
    state = %__MODULE__{
      guild_id: guild_id,
      # text channel
      channel_id: channel_id
    }

    {:ok, state}
  end

  def handle_cast(
        {:dispatch, %{"op" => "event", "reason" => reason, "type" => "TrackEndEvent"}},
        %__MODULE__{} = state
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
    Logger.debug(fn -> "[Lavalink][Player][Other Event]: #{inspect(event)}" end)
    {:noreply, state}
  end

  def handle_call(
        {:queue, [track | _tracks] = tracks},
        _from,
        %__MODULE__{queue: queue, guild_id: guild_id} = state
      )
      when is_list(tracks) do
    should_start = :queue.is_empty(queue)
    queue = Enum.reduce(tracks, queue, &:queue.in/2)

    state =
      if should_start do
        50
        |> Payload.volume(guild_id)
        |> Connection.send()

        play(track, state)
      else
        state
      end

    {:reply, should_start, Map.put(state, :queue, queue)}
  end

  def handle_call(:queue, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:loop, :show}, _from, state) do
    {:reply, loop_state(state), state}
  end

  def handle_call({:loop, new_loop_state}, _from, state) do
    state = Map.put(state, :loop, new_loop_state)

    {:reply, loop_state(state), state}
  end

  def handle_call(pause_or_resume, _from, %__MODULE__{guild_id: guild_id} = state)
      when pause_or_resume in [:pause, :resume] do
    pause = pause_or_resume == :pause

    pause
    |> Payload.pause(guild_id)
    |> Connection.send()

    res =
      cond do
        pause && state.paused ->
          :LOC_MUSIC_ALREADY_PAUSED

        pause && !state.paused ->
          :LOC_MUSIC_PAUSED

        !pause && state.paused ->
          :LOC_MUSIC_RESUMED

        pause && state.paused ->
          :LOC_MUSIC_AREADY_PLAYING
      end

    {:reply, res, Map.put(state, :paused, pause)}
  end

  def handle_call(:skip, _from, %__MODULE__{queue: queue, guild_id: guild_id} = state) do
    res =
      case :queue.peek(queue) do
        {:value, {_author, current}} ->
          time =
            current.info.length
            |> Util.format_milliseconds()

          {:LOC_MUSIC_JUST_SKIPPED, [title: current.info.title, time: time]}

        :empty ->
          :LOC_MUSIC_QUEUE_EMPTY
      end

    guild_id
    |> Payload.stop()
    |> Connection.send()

    {:reply, res, state}
  end

  def handle_call(:stop, _from, %__MODULE__{guild_id: guild_id, queue: queue} = state) do
    first = :queue.get(queue)

    guild_id
    |> Payload.stop()
    |> Connection.send()

    queue = :queue.in(first, :queue.new())

    {:reply, :LOC_MUSIC_STOPPED, Map.put(state, :queue, queue)}
  end

  def handle_call(:shuffle, _from, %__MODULE__{queue: queue} = state) do
    [first | rest] = :queue.to_list(queue)
    rest = Enum.shuffle(rest)
    queue = :queue.from_list([first | rest])

    {:reply, :LOC_MUSIC_SHUFFLED, Map.put(state, :queue, queue)}
  end

  @spec play_next(state :: map()) :: {:ok, map()} | {:error, :empty | :end, map()}
  defp play_next(%__MODULE__{queue: queue, guild_id: guild_id} = state) do
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

  @spec play(term(), t()) :: t()
  defp play(
         {author, %{track: track, info: info}},
         %__MODULE__{guild_id: guild_id, channel_id: channel_id} = state
       ) do
    locale = Locale.fetch!(guild_id)

    embed =
      info
      |> Util.build_embed(author, "play")
      |> Locale.localize_embed(locale)

    message =
      rest(:create_message!, [
        channel_id,
        [embed: embed]
      ])

    track
    |> Payload.play(guild_id)
    |> Connection.send()

    Map.put(state, :message, message)
  end

  defp loop_state(%{loop: true}), do: :LOC_MUSIC_LOOP_ENABLED
  defp loop_state(%{loop: false}), do: :LOC_MUSIC_LOOP_DISABLED
end
