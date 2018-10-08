defmodule Bot.Handler.Command.Music.Shuffle do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Mutil

  import Bot.Handler.Util

  def description(), do: :LOC_DESC_SHUFFLE
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(
        %{author: %{id: user_id}},
        %{id: guild_id, voice_states: voice_states}
      ) do
    res =
      with true <- Mutil.ensure_connected(voice_states, user_id) do
        lavalink(Player, :command, [guild_id, :shuffle])
      end

    {:respond, res}
  end
end
