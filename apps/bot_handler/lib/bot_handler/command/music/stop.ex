defmodule Bot.Handler.Command.Music.Stop do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def description(),
    do: "Stops the currently played song, clears the queue, and disconnects the bot."

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
        Music.Player.command(guild_id, :stop)
      end

    {:respond, res}
  end
end
