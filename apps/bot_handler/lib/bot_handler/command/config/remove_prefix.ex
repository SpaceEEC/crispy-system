defmodule Bot.Handler.Command.Config.RemovePrefix do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Command
  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  def description(), do: :LOC_DESC_PREFIX
  def guild_only(), do: true

  def inhibit(%{member: member, guild_id: guild_id}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    member
    |> Permissions.from(guild)
    |> Permissions.has(:manage_guild) || {:respond, :LOC_REMOVEPREFIX_PERMS}
  end

  def process(%{guild_id: guild_id}, _) do
    response =
      case Guild.delete!(guild_id, "prefix") do
        0 ->
          {:LOV_REMOVEPREFIX_NONE, [default: Command.get_prefix()]}

        _ ->
          {:LOV_REMOVEPREFIX_REMOVED, [default: Command.get_prefix()]}
      end

    {:respond, response}
  end
end
