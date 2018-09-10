defmodule Bot.Handler.Command.Config.VlogChannel do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  def usages(), do: ["", "<\"remove\"|text-channel>"]
  def examples(), do: ["", "remove", "#text-channel"]

  def description(),
    do: "See, set, or remove the current voice log channel from the configuration."

  def inhibit(%{guild_id: nil}, _) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(%{member: member, guild_id: guild_id, author: %{id: user_id}}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    Permissions.from(member, guild)
    |> Permissions.has(:manage_guild) ||
      {:respond,
       "You do not have the required manage guild permission to see or modify the voice log channel."}
  end

  def fetch(_message, []), do: {:ok, :show}
  def fetch(_message, ["remove" | _]), do: {:ok, :remove}

  def fetch(%{guild_id: guild_id}, ["<#" <> rest | _]) do
    id = String.slice(rest, 0..-2)

    case cache(:Channel, :fetch, [id]) do
      :error ->
        {:respond, "Could not find a channel with the id #{id} from <##{id}>."}

      {:ok, %{guild_id: other_guild_id}} when guild_id != other_guild_id ->
        {:respond, "The requested channel is not in this guild."}

      {:ok, %{type: 0} = channel} ->
        {:ok, [channel.id]}

      {:ok, channel} ->
        {:respond, "#{channel} is not a text channel."}
    end
  end

  def fetch(_message, _args) do
    {:respond, "Pass either nothing, \"remove\", or a channel mention."}
  end

  def process(%{guild_id: guild_id}, :show) do
    case Guild.get!(guild_id, "vlog_channel_id") do
      nil ->
        "No voice log channel was set up."

      id ->
        "The current voice log channel is <##{id}>."
    end
  end

  def process(%{guild_id: guild_id}, :remove) do
    case Guild.delete!(guild_id, "vlog_channel_id") do
      1 ->
        "Removed the set voice log channel from the configuration."

      0 ->
        "No voice log channel was set up."
    end
  end

  def process(%{guild_id: guild_id}, channel_id) do
    Guild.put!(guild_id, "vlog_channel_id", channel_id)

    {:respond, "Set the voice log channel to <##{channel_id}>"}
  end
end
