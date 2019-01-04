defmodule Bot.Cache.Consumer do
  @moduledoc """
    Handles consuming and processing of events received from the gateway.
    To consume those processed events subscribe with a consumer to a `Crux.Base.Producer`.
  """

  use GenStage

  alias Bot.Cache.Producer
  alias Crux.Base.Consumer

  @gateway :"bot_gateway@127.0.0.1"
  @registry Bot.Cache.Registry

  @doc false
  def start_link(shard_id) do
    name = {:via, Registry, {@registry, shard_id}}
    GenStage.start_link(__MODULE__, shard_id, name: name)
  end

  @doc false
  def init(shard_id) do
    require Logger

    with :pong <- Node.ping(@gateway),
         %{^shard_id => pid} <-
           :rpc.call(@gateway, Crux.Gateway.Connection.Producer, :producers, []) do
      Logger.info("[Bot][Cache][Consumer]: Connected to gateway producer for shard #{shard_id}")
      {:consumer, nil, subscribe_to: [pid]}
    else
      _ ->
        Logger.warn("[Bot][Cache][Consumer]: Gateway down waiting 10 seconds.")
        Process.sleep(10_000)
        init(shard_id)
    end
  end

  @doc false
  def handle_events(events, _from, nil) do
    for {type, data, shard_id} <- events,
        value <- [Consumer.handle_event(type, data, shard_id)],
        value != nil do
      Producer.dispatch({type, value, shard_id})
    end

    {:noreply, [], nil}
  end

  def handle_events(events, from, _other), do: handle_events(events, from, nil)

  @doc false

  def handle_cancel({:down, :noconnection}, _, nil) do
    require Logger

    Logger.warn("[Bot][Cache][Consumer]: Gateway producer down, waiting 10 seconds.")
    Process.sleep(10_000)

    {:noreply, [], nil}
  end
end
