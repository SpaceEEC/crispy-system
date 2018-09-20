defmodule Bot.Handler.Command.Music.Loop do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def usages(), do: ["", "<State>"]
  def examples(), do: ["", "enable", "disable"]
  def description(), do: "Enabled, disabled, or shows the current state of the queue."
  def guild_only(), do: true

  def fetch(message, []), do: fetch(message, [""])

  def fetch(%{guild_id: guild_id}, args) do
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
      with true <- Music.Util.ensure_connected(guild.voice_states, user_id) do
        Music.Player.command(guild.id, {:loop, state})
      end

    {:respond, res}
  end
end
