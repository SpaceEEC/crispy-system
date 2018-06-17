defmodule Bot.Handler.Command.Leave do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music.Util
  alias Crux.Structs.Message

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil} = message, _) do
    rest(:create_message, [message, [content: "That command may not be used in dms."]])
  end

  def inhibit(_message, _args), do: true

  def handle(%Message{author: %{id: user_id}} = message, _args) do
    channel = cache(Channel, :fetch!, [message.channel_id])
    guild = cache(Guild, :fetch!, [channel.guild_id])
    %{id: own_id} = cache(User, :me!)

    res =
      with true <- Util.ensure_connected(guild.voice_states, own_id, user_id) do
        gateway(Bot.Gateway, :voice_state_update, [guild.id])

        "Leaving you..."
      end

    rest(:create_message, [message, [content: res]])
  end
end
