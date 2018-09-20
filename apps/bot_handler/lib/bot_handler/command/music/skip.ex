defmodule Bot.Handler.Command.Music.Skip do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def description(), do: "Skips the currently played song."
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(
        %{author: %{id: user_id}},
        %{id: guild_id, voice_states: voice_states}
      ) do
    res =
      with true <- Music.Util.ensure_connected(voice_states, user_id) do
        Music.Player.command(guild_id, :skip)
      end

    {:respond, res}
  end
end
