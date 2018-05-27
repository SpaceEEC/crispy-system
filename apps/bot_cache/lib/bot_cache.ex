defmodule Bot.Cache.Application do
  @moduledoc false

  use Application

  @gateway :"gateway@127.0.0.1"
  @registry Bot.Cache.Registry

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    with {:badrpc, reason} <- :rpc.call(@gateway, Bot.Gateway, :start, []) do
      raise inspect(reason)
    end

    children =
      for {shard_id, producer} <-
            :rpc.call(@gateway, Crux.Gateway.Connection.Producer, :producers, []) do
        [
          Supervisor.child_spec(
            {Bot.Cache.Consumer, {shard_id, producer}},
            id: "consumer_#{shard_id}"
          ),
          Supervisor.child_spec(
            {Bot.Cache.Producer, shard_id},
            id: "producer_#{shard_id}"
          )
        ]
      end
      |> Enum.flat_map(fn element -> element end)

    children = [{Registry, keys: :unique, name: @registry} | children]

    Supervisor.start_link(children, strategy: :one_for_one, name: Bot.Cache.Supervisor)
  end

  def producers do
    Supervisor.which_children(Bot.Cache.Supervisor)
    |> Enum.reduce(Map.new(), fn {id, pid, _type, _modules}, acc ->
      case id do
        "producer_" <> id ->
          Map.put(acc, String.to_integer(id), pid)

        _ ->
          acc
      end
    end)
  end
end
