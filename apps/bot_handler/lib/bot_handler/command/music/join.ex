defmodule Bot.Handler.Command.Music.Join do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil}, _) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(_message, _args), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    guild = cache(Guild, :fetch!, [guild_id])
    {:ok, guild}
  end

  def process(%{author: %{id: user_id}}, %{id: guild_id, voice_states: voice_states}) do
    case voice_states do
      %{^user_id => %{channel_id: channel_id}} when not is_nil(channel_id) ->
        gateway(Bot.Gateway, :voice_state_update, [guild_id, channel_id])

        {:respond, "Joining you..."}

      _ ->
        {:respond, "You don't look connected to me."}
    end
  end
end
