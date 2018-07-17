defmodule Bot.Handler.Command.Music.Loop do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil}, _) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(_message, _args), do: true

  def fetch(message, []), do: fetch(message, [""])

  def fetch(%{guild_id: guild_id}, args) do
    guild = cache(Guild, :fetch!, [guild_id])
    %{id: own_id} = cache(User, :me!)

    {:ok, {own_id, guild, args}}
  end

  def process(%{author: %{id: user_id}}, {own_id, guild, [args | _rest]}) do
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
      with true <- Music.Util.ensure_connected(guild.voice_states, own_id, user_id) do
        Music.Player.command(guild.id, {:loop, state})
      end

    {:respond, res}
  end
end
