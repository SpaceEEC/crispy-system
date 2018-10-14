defmodule Bot.Handler.Command.Music.Resume do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Mutil

  import Bot.Handler.Rpc

  def description(), do: :LOC_DESC_RESUME
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(%{author: %{id: user_id}}, guild) do
    res =
      with true <- Mutil.ensure_connected(guild.voice_states, user_id) do
        lavalink(Player, :command, [guild.id, :resume])
      end

    {:respond, res}
  end
end
