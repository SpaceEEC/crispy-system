defmodule Bot.Handler.Command.Music.Join do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  def description(), do: :LOC_DESC_JOIN
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    guild = cache(:Guild, :fetch!, [guild_id])
    {:ok, guild}
  end

  def process(%{author: %{id: user_id}}, %{id: guild_id, voice_states: voice_states}) do
    case voice_states do
      %{^user_id => %{channel_id: channel_id}} when not is_nil(channel_id) ->
        gateway(Bot.Gateway, :voice_state_update, [guild_id, channel_id])

        {:respond, :LOC_MUSIC_JOINING}

      _ ->
        {:respond, :LOC_MUSIC_NOT_CONNECTED}
    end
  end
end
