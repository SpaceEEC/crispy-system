defmodule Bot.Handler.Command.Config.Prefix do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Command
  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  @spec description() :: String.t() | atom()
  def description(), do: :LOC_DESC_PREFIX
  def examples(), do: ["", "!"]
  def guild_only(), do: true
  def usages(), do: ["", "<NewPrefix>"]

  def inhibit(_message, %{args: []}), do: true

  def inhibit(%{member: member, guild_id: guild_id}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    member
    |> Permissions.from(guild)
    |> Permissions.has(:manage_guild)
    |> Kernel.||({:respond, :LOC_PREFIX_PERMS})
  end

  def process(%{guild_id: guild_id}, %{args: []}) do
    prefix = Guild.get!(guild_id, "prefix", Command.get_prefix())

    {:respond, {:LOC_PREFIX_CURRENT, [prefix: prefix]}}
  end

  def process(%{guild_id: guild_id}, %{args: args}) do
    old_prefix = Guild.get!(guild_id, "prefix", Command.get_prefix())
    new_prefix = Enum.join(args, " ")

    Guild.put!(guild_id, "prefix", new_prefix)

    response =
      if old_prefix,
        do: {:LOC_PREFIX_CHANGED, [old: old_prefix, new: new_prefix]},
        else: {:LOC_PREFIX_SET, [new: new_prefix]}

    {:respond, response}
  end
end
