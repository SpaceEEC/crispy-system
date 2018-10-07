defmodule Bot.Cache.Application do
  @moduledoc false

  use Application

  @gateway :"gateway@127.0.0.1"
  @registry Bot.Cache.Registry

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    case Node.ping(@gateway) do
      :pong ->
        children =
          for {shard_id, _pid} <-
                :rpc.call(@gateway, Crux.Gateway.Connection.Producer, :producers, []) do
            [
              Supervisor.child_spec(
                {Bot.Cache.Consumer, shard_id},
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

      :pang ->
        {:error, :gateway_not_started}
    end
  end

  def producers do
    Bot.Cache.Supervisor
    |> Supervisor.which_children()
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
