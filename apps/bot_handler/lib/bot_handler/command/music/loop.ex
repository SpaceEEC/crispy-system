defmodule Bot.Handler.Command.Music.Loop do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Util
  import Bot.Handler.Rpc

  def usages(), do: ["", "<State>"]
  def examples(), do: ["", "enable", "disable"]
  def description(), do: :LOC_DESC_LOOP
  def guild_only(), do: true

  def inhibit(_, _) do
    Node.ping(lavalink()) == :pong || {:respond, {:LOC_NODE_OFFLINE, [node: lavalink()]}}
  end

  def fetch(message, %{args: []} = info), do: fetch(message, %{info | args: [""]})

  def fetch(%{guild_id: guild_id}, %{args: args}) do
    {:ok, {cache(:Guild, :fetch!, [guild_id]), args}}
  end

  def process(%{author: %{id: user_id}}, {guild, [args | _rest]}) do
    state =
      cond do
        args in ["enable", "yes", "on", "1", "y"] ->
          true

        args in ["disable", "no", "off", "0,", "n"] ->
          false

        true ->
          :show
      end

    res =
      with true <- Util.ensure_connected(guild.voice_states, user_id) do
        lavalink(Player, :command, [guild.id, {:loop, state}])
      end

    {:respond, res}
  end
end
