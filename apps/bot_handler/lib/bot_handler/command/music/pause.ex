defmodule Bot.Handler.Command.Music.Pause do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music.{Player, Util}

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil}, _) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(_message, _args), do: true

  def fetch(%{guild_id: guild_id}, _args) do
    guild = cache(Guild, :fetch!, [guild_id])
    %{id: own_id} = cache(User, :me!)

    {:ok, {own_id, guild}}
  end

  def process(
        %{author: %{id: user_id}},
        {own_id, %{id: guild_id, voice_states: voice_states}}
      ) do
    res =
      with true <- Util.ensure_connected(voice_states, own_id, user_id) do
        Player.command(guild_id, :pause)
      end

    {:respond, res}
  end
end