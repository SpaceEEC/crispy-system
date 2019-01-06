defmodule Bot.Handler.Command.Music.Join do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Rpc

  def description(), do: :LOC_DESC_JOIN
  def guild_only(), do: true

  def inhibit(_, _) do
    Node.ping(lavalink()) == :pong || {:respond, {:LOC_NODE_OFFLINE, [node: lavalink()]}}
  end

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(%{author: %{id: user_id}}, %{id: guild_id, voice_states: voice_states}) do
    case voice_states do
      %{^user_id => %{channel_id: channel_id}} when not is_nil(channel_id) ->
        gateway(Bot.Gateway, :voice_state_update, [guild_id, channel_id])

        {:respond, :LOC_MUSIC_JOINING}

      _ ->
        {:respond, :LOC_MUSIC_NOT_CONNECTED}
    end
  end
end
