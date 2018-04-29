defmodule Bot.Handler.Command.Loop do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def handle(message, []), do: handle(message, [""])

  def handle(%{author: %{id: user_id}} = message, [args | _rest]) do
    channel = cache(Channel, :fetch!, [message.channel_id])
    guild = cache(Guild, :fetch!, [channel.guild_id])
    %{id: own_id} = cache(User, :me!)

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
      with true <- Music.Util.ensure_connected(guild.voice_states, own_id, user_id),
           do: Music.Player.command(guild.id, {:loop, state})

    rest(:create_message, [message, [content: res]])
  end
end
