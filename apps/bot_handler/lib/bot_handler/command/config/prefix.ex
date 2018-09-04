defmodule Bot.Handler.Command.Config.Prefix do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Crux.Structs.Permissions

  def inhibit(_message, []), do: true

  def inhibit(%{channel_id: channel_id, guild_id: guild_id, author: %{id: user_id}}, _) do
    guild = cache(Guild, :fetch!, [guild_id])
    channel = cache(Channel, :fetch!, [channel_id])

    member = case guild.members do
      %{^user_id => member} ->
        member
      _ ->
        rest(:get_guild_member!, [guild, user_id])
    end

    Permissions.from(member, guild, channel)
    |> Permissions.has(:manage_guild) ||
      {:respond, "You do not have the manage guild permission required to set the prefix."}
  end

  def process(%{guild_id: guild_id}, []) do
    prefix = Bot.Handler.Etcd.get!("#{guild_id}:prefix")

    response =
      if prefix,
        do: "The current prefix is ``#{prefix}``.",
        else: "There is no custom prefix set."

    {:respond, response}
  end

  def process(%{guild_id: guild_id}, args) do
    old_prefix = Bot.Handler.Etcd.get!("#{guild_id}:prefix")
    new_prefix = Enum.join(args, " ")

    Bot.Handler.Etcd.put!("#{guild_id}:prefix", new_prefix)

    response =
      if old_prefix,
        do: "Prefix changed from ``#{old_prefix}`` to ``#{new_prefix}``.",
        else: "Prefix set to ``#{new_prefix}``."

    {:respond, response}
  end
end
