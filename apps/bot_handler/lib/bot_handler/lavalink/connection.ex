defmodule Bot.Handler.Lavalink.Connection do
  use WebSockex

  require Logger

  alias Crux.Structs.VoiceState

  import Bot.Handler.Util

  def start_link(_) do
    Logger.info("[Lavalink]: Starting WebSocket connection")

    shard_count = gateway(Application, :fetch_env!, [:crux_gateway, :shard_count])
    %{id: id} = cache(User, :me!)

    WebSockex.Conn.new(
      "ws://localhost:8080",
      extra_headers: [
        {"Authorization", "12345"},
        {"Num-Shards", shard_count},
        {"User-Id", id}
      ]
    )
    |> WebSockex.start_link(
      __MODULE__,
      [%{}],
      name: __MODULE__,
      handle_initial_conn_failure: true,
      async: true
    )
  end

  def send(%{} = data) do
    data
    |> Poison.encode!()
    |> send()
  end

  # https://github.com/Frederikam/Lavalink/blob/master/IMPLEMENTATION.md#outgoing-messages
  def send(data) do
    Logger.debug("[Lavalink][send]: #{inspect(data)}")

    WebSockex.send_frame(__MODULE__, {:text, data})
  end

  def forward(data), do: WebSockex.cast(__MODULE__, {:store, data})

  def try_join(
        %{guild_id: guild_id, session_id: session_id},
        %{} = voice_server,
        state
      ) do
    packet =
      %{"op" => "voiceUpdate", "guildId" => "#{guild_id}", sessionId: session_id}
      |> Map.put(:event, voice_server)
      |> Poison.encode!()

    {:reply, {:text, packet}, state}
  end

  def try_join(_, _, state), do: {:ok, state}

  def terminate(reason, %{shard_id: shard_id}) do
    Logger.warn("[Crux][Gateway][Shard #{shard_id}]: Terminating duo #{inspect(reason)}")
  end

  def handle_cast({:store, %VoiceState{guild_id: guild_id} = voice_state}, state),
    do: try_join(voice_state, Map.get(state, guild_id), state)

  def handle_cast({:store, %{guild_id: guild_id} = voice_server}, state) do
    voice_server = Map.update!(voice_server, :guild_id, &Integer.to_string/1)
    state = Map.put(state, guild_id, voice_server)

    %{id: own_id} = cache(User, :me!)

    cache(Guild, :fetch!, [guild_id])
    |> Map.get(:voice_states)
    |> Map.get(own_id)
    |> try_join(voice_server, state)
  end

  def handle_connect(_, [state]) do
    Logger.info("[Lavalink]: Established connection")

    {:ok, state}
  end

  def handle_connect(_, state) do
    Logger.info("[Lavalink]: Reconnected")

    {:ok, state}
  end

  def handle_disconnect(%{reason: {:remote, code, reason}}, state) do
    Logger.warn("[Lavalink]: Disconnected: #{code} - #{reason}")

    {:reconnect, state}
  end

  def handle_frame({:text, frame}, state) do
    spawn(fn ->
      frame
      |> Poison.decode!()
      |> Bot.Handler.Music.Supervisor.try_dispatch()
    end)

    # Logger.debug("[Lavalink][handle_frame]: #{frame}")

    {:ok, state}
  end
end
