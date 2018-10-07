defmodule Bot.Handler.Command.Config.RemovePrefix do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Command
  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  def description(), do: "Remove the currently set prefix."
  def guild_only(), do: true

  def inhibit(%{member: member, guild_id: guild_id}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    member
    |> Permissions.from(guild)
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
