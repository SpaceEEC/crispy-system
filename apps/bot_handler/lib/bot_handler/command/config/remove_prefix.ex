defmodule Bot.Handler.Command.Config.RemovePrefix do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Command
  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  def description(), do: "Remove the currently set prefix."

  def inhibit(%{channel_id: channel_id, guild_id: guild_id, author: %{id: user_id}}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])
    channel = cache(:Channel, :fetch!, [channel_id])

    member =
      case guild.members do
        %{^user_id => member} ->
          member

        _ ->
          rest(:get_guild_member!, [guild, user_id])
      end

    Permissions.from(member, guild, channel)
    |> Permissions.has(:manage_guild) ||
      {:respond, "You do not have the required manage guild permission to remove the prefix."}
  end

  def process(%{guild_id: guild_id}, _) do
    response =
      case Guild.delete!(guild_id, "prefix") do
        0 ->
          "No custom prefix to remote is set, the default one is ``#{Command.get_prefix()}``."

        _ ->
          "Custom prefix had been removed, now using default prefix ``#{Command.get_prefix()}``."
      end

    {:respond, response}
  end
end
