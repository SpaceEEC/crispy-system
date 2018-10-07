defmodule Bot.Lavalink.Player.Supervisor do
  @moduledoc false

  use Supervisor
  require Logger

  alias Bot.Lavalink.Player

  @registry Bot.Lavalink.Player.Registry

  def start_link(_) do
    Supervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    Logger.info("[MusicSupervisor]: init/1")

    children = [
      {Registry, keys: :unique, name: @registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def try_dispatch(%{"guildId" => guild_id} = event) do
    with {:ok, pid} <- Player.lookup(String.to_integer(guild_id)) do
      GenServer.cast(pid, {:dispatch, event})
    end
  end

  def try_dispatch(_other) do
    # Logger.info("[Player]: Recieved other dispatch #{inspect(other)}")
  end

  def start_child({guild_id, _channel_id} = state) do
    Logger.info("[MusicSupervisor]: Starting player for guild #{guild_id}")

    Supervisor.start_child(
      __MODULE__,
      Supervisor.child_spec(
        {Player, state},
        id: guild_id,
        restart: :temporary
      )
    )
  end
end
