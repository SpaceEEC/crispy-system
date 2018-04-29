defmodule Bot.Gateway do
  alias Crux.Gateway

  @rest :rest@localhost

  def start do
    {:ok, %{"shards" => shard_count, "url" => url}} =
      :rpc.call(@rest, Crux.Rest, :gateway_bot, [])

    Gateway.start(%{
      shard_count: shard_count,
      url: url
    })
  end

  def voice_state_update(guild_id, channel_id, states \\ []) do
    use Bitwise

    shard_count = Application.fetch_env!(:crux_gateway, :shard_count)
    shard_id = guild_id >>> 22 |> rem(shard_count)

    Gateway.Command.voice_state_update(guild_id, channel_id, states)
    |> Gateway.Connection.send_command(shard_id)
  end
end
