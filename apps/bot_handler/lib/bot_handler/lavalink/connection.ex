defmodule Bot.Handler.Lavalink.Connection do
  use WebSockex

  require Logger

  alias Crux.Structs.VoiceState
  alias Bot.Handler.Lavalink.Payload

  import Bot.Handler.Util

  @spec start_link(term()) :: {:ok, pid()} | {:error, term()}
  def start_link(_ \\ []) do
    Logger.info("[Lavalink]: Starting WebSocket connection")

    shard_count = gateway(Application, :fetch_env!, [:crux_gateway, :shard_count])
    %{id: id} = cache(:User, :me!)

    voice_servers = Map.new()
    voice_states = Map.new()

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
      [{voice_servers, voice_states}],
      name: __MODULE__,
      handle_initial_conn_failure: true,
      async: true
    )
  end

  @spec send(data :: map()) :: term()
  def send(%{} = data) do
    data
    |> Poison.encode!()
    |> send()
  end

  # https://github.com/Frederikam/Lavalink/blob/master/IMPLEMENTATION.md#outgoing-messages
  @spec send(data :: String.t()) :: term()
  def send(data) do
    Logger.debug("[Lavalink][send]: #{inspect(data)}")

    WebSockex.send_frame(__MODULE__, {:text, data})
  end

  @spec forward(data :: term()) :: :ok

  def forward(%VoiceState{channel_id: nil}), do: :ok

  def forward(%VoiceState{user_id: id} = voice_state) do
    case cache(:User, :me) do
      {:ok, %{id: ^id}} ->
        WebSockex.cast(__MODULE__, {:store, voice_state})

      _ ->
        :ok
    end
  end

  def forward(data) do
    # IO.inspect(data, label: "forward")
    WebSockex.cast(__MODULE__, {:store, data})
  end

  def try_join(
        guild_id,
        {voice_servers, voice_states} = state
      ) do
    voice_server = Map.get(voice_servers, guild_id)
    # |> IO.inspect(label: "voice_server #{inspect guild_id}")
    # IO.inspect(Map.keys(voice_servers), label: "keys")

    voice_state = Map.get(voice_states, guild_id)
    # |> IO.inspect(label: "voice_state #{inspect guild_id}")
    # IO.inspect(Map.keys(voice_states), label: "keys")

    if voice_server && voice_state do
      packet =
        Payload.voice_update(voice_server, voice_state.session_id, to_string(guild_id))
        |> Poison.encode!()

      {:reply, {:text, packet}, state}
    else
      {:ok, state}
    end
  end

  def terminate(reason, _state) do
    Logger.warn("[Lavalink]: Terminating due to #{inspect(reason)}")
  end

  def handle_cast(
        {:store, %VoiceState{guild_id: guild_id} = voice_state},
        {voice_servers, voice_states}
      ) do
    try_join(
      guild_id,
      {
        voice_servers,
        Map.put(voice_states, guild_id, voice_state)
      }
    )
  end

  def handle_cast({:store, %{guild_id: guild_id} = voice_server}, {voice_servers, voice_states}) do
    # Lavalink can not handle integer guild ids. One might think it's written in JavaScript...
    voice_server = Map.update!(voice_server, :guild_id, &Integer.to_string/1)
    voice_servers = Map.put(voice_servers, guild_id, voice_server)

    try_join(guild_id, {voice_servers, voice_states})
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

  def handle_disconnect(other, state) do
    Logger.warn("[Lavalink]: Terminating due to #{inspect(other)}; Reconnecting in 5 seconds.")
    :timer.sleep(5000)
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
