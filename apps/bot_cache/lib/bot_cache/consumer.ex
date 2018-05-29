defmodule Bot.Cache.Consumer do
  @moduledoc """
    Handles consuming and processing of events received from the gateway.
    To consume those processed events subscribe with a consumer to a `Crux.Base.Producer`.
  """

  use GenStage

  @registry Bot.Cache.Registry

  @doc false
  def start_link({shard_id, target}) do
    name = {:via, Registry, {@registry, shard_id}}
    GenStage.start_link(__MODULE__, target, name: name)
  end

  @doc false
  def init(target) do
    {:consumer, nil, subscribe_to: [target]}
  end

  @doc false
  def handle_events(events, _from, nil) do
    for {type, data, shard_id} <- events,
        value <- [Crux.Base.Consumer.handle_event(type, data, shard_id)],
        value != nil do
      Bot.Cache.Producer.dispatch({type, value, shard_id})
    end

    {:noreply, [], nil}
  end
end
