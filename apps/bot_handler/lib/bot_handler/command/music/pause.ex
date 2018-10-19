defmodule Bot.Handler.Command.Music.Pause do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Util

  import Bot.Handler.Rpc

  def description(), do: :LOC_DESC_PAUSE
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(
        %{author: %{id: user_id}},
        %{id: guild_id, voice_states: voice_states}
      ) do
    res =
      with true <- Util.ensure_connected(voice_states, user_id) do
        lavalink(Player, :command, [guild_id, :pause])
      end

    {:respond, res}
  end
end
