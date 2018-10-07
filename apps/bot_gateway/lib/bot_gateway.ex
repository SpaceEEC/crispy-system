defmodule Bot.Gateway do
  @moduledoc false

  alias Crux.Gateway
  alias Crux.Gateway.{Command, Connection}

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

        {:ok, spawn(fn -> :timer.sleep(:infinity) end)}

      :pang ->
        {:error, :rest_not_started}
    end
  end

  def stop(_) do
    :application.stop(:crux_gateway)
  end

  @spec voice_state_update(
          guild_id :: Crux.Rest.snowflake(),
          channel_id :: Crux.Rest.snowflake() | nil,
          states :: [{:self_mute, boolean()} | {:self_deaf, boolean()}]
        ) :: :ok | {:error, term()}
  def voice_state_update(guild_id, channel_id \\ nil, states \\ []) do
    use Bitwise

    shard_count = Application.fetch_env!(:crux_gateway, :shard_count)
    shard_id = guild_id |> bsr(22) |> rem(shard_count)

    guild_id
    |> Command.voice_state_update(channel_id, states)
    |> Connection.send_command(shard_id)
  end
end
