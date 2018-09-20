defmodule Bot.Handler.Command.Config.Prefix do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Command
  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  def description(), do: "Set or display the current prefix."
  def examples(), do: ["", "!"]
  def guild_only(), do: true
  def usages(), do: ["", "<NewPrefix>"]

  def inhibit(%{member: member, guild_id: guild_id}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    Permissions.from(member, guild)
    |> Permissions.has(:manage_guild) ||
      {:respond, "You do not have the manage guild permission required to set the prefix."}
  end

  def process(%{guild_id: guild_id}, []) do
    prefix = Guild.get!(guild_id, "prefix", Command.get_prefix())

    {:respond, "The current prefix is ``#{prefix}``."}
  end

  def process(%{guild_id: guild_id}, args) do
    old_prefix = Guild.get!(guild_id, "prefix", Command.get_prefix())
    new_prefix = Enum.join(args, " ")

    Guild.put!(guild_id, "prefix", new_prefix)

    response =
      if old_prefix,
        do: "Prefix changed from ``#{old_prefix}`` to ``#{new_prefix}``.",
        else: "Prefix set to ``#{new_prefix}``."

    {:respond, response}
  end
end
