defmodule Bot.Handler.Command.Music.Resume do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def description(), do: "Resumes the currently paused song"
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(%{author: %{id: user_id}}, guild) do
    res =
      with true <- Music.Util.ensure_connected(guild.voice_states, user_id) do
        Music.Player.command(guild.id, :resume)
      end

    {:respond, res}
  end
end
