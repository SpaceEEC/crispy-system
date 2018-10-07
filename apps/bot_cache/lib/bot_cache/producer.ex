defmodule Bot.Cache.Producer do
  @moduledoc """
    Handles dispatching of packets received from the gateway producers
    after they were consumed and processed by `Crux.Base.Consumer`.
  """

  use GenStage

  @registry Bot.Cache.Registry

  @doc false
  def start_link(shard_id) do
    name = {:via, Registry, {@registry, {:producer, shard_id}}}

    GenStage.start_link(__MODULE__, nil, name: name)
  end

  @doc false
  def dispatch({_, nil, _nil}), do: nil

  def dispatch({type, data, shard_id}) do
    with [{pid, _other}] <- Registry.lookup(@registry, {:producer, shard_id}),
         true <- Process.alive?(pid) do
      GenStage.cast(pid, {:dispatch, {type, data, shard_id}})
    else
      _ ->
        require Logger
        Logger.warn("[Bot][Cache][Producer]: Missing producer for shard #{shard_id}; #{type}")
    end
  end

  # Queue
  # rear - tail (in)
  # elements
  # elements
  # more elements
  # front - head (out)

  @doc false
  def init(_state) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  @doc false
  def handle_cast({:dispatch, event}, {queue, demand}) do
    event
    |> :queue.in(queue)
    |> dispatch_events(demand, [])
  end

  @doc false
  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, incoming_demand + demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
         {{:value, event}, queue} <- :queue.out(queue) do
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
