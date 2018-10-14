defmodule Bot.Handler.Command.Music.Leave do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Mutil

  import Bot.Handler.Rpc

  def description(), do: :LOC_DESC_LEAVE
  def guild_only(), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    {:ok, cache(:Guild, :fetch!, [guild_id])}
  end

  def process(
        %{author: %{id: user_id}},
        %{id: guild_id, voice_states: voice_states}
      ) do
    # Util.ensure_connected returns a string explaining what's wrong if there is something wrong
    response =
      with true <- Mutil.ensure_connected(voice_states, user_id) do
        gateway(Bot.Gateway, :voice_state_update, [guild_id])

        :LOC_MUSIC_LEAVING
      end

    {:respond, response}
  end
end
