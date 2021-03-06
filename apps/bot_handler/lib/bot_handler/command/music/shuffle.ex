defmodule Bot.Handler.Command.Music.Shuffle do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Util

  import Bot.Handler.Rpc

  def description(), do: :LOC_DESC_SHUFFLE
  def guild_only(), do: true

  def inhibit(_, _) do
    Node.ping(lavalink()) == :pong || {:respond, {:LOC_NODE_OFFLINE, [node: lavalink()]}}
  end

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(
        %{author: %{id: user_id}},
        %{id: guild_id, voice_states: voice_states}
      ) do
    res =
      with true <- Util.ensure_connected(voice_states, user_id) do
        lavalink(Player, :command, [guild_id, :shuffle])
      end

    {:respond, res}
  end
end
