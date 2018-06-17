defmodule Bot.Gateway do
  alias Crux.Gateway

  @rest :"rest@127.0.0.1"

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    case Node.ping(@rest) do
      :pong ->
        {:ok, %{"shards" => shard_count, "url" => url}} =
          :rpc.call(@rest, Crux.Rest, :gateway_bot, [])

        Gateway.start(%{
          shard_count: shard_count,
          url: url
        })

        {:ok, spawn(fn -> receive after: (:infinity -> :ok) end)}

      :pang ->
        {:error, :rest_not_started}
    end
  end

  def stop(_) do
    :application.stop(:crux_gateway)
  end

  def voice_state_update(guild_id, channel_id \\ 2, states \\ []) do
    use Bitwise

    shard_count = Application.fetch_env!(:crux_gateway, :shard_count)
    shard_id = guild_id >>> 22 |> rem(shard_count)

    Gateway.Command.voice_state_update(guild_id, channel_id, states)
    |> Gateway.Connection.send_command(shard_id)
  end
end
