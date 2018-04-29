defmodule Bot.Handler.Command.Join do
  @behaviour Bot.Handler.Command

  alias Crux.Structs.VoiceState

  import Bot.Handler.Util

  def handle(%{author: %{id: user_id}} = message, _args) do
    channel = cache(Channel, :fetch!, [message.channel_id])
    guild = cache(Guild, :fetch!, [channel.guild_id])

    case guild.voice_states do
      %{^user_id => %VoiceState{channel_id: channel_id}} when not is_nil(channel_id) ->

        gateway(Bot.Gateway, :voice_state_update, [guild.id, channel_id])

        rest(:create_message, [message, [content: "Joining you..."]])

      _ ->
        rest(:create_message, [message, [content: "You don't look connected to me."]])
    end
  end
end
