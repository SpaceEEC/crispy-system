defmodule Bot.Handler.Command.Config.VlogChannel do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Rpc

  alias Bot.Handler.Config.Guild
  alias Crux.Structs.Permissions

  def description(), do: :LOC_DESC_VLOG

  def examples(), do: ["", "remove", "#text-channel"]
  def guild_only(), do: true
  def usages(), do: ["", "<\"remove\"|text-channel>"]

  def inhibit(%{member: member, guild_id: guild_id}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    member
    |> Permissions.from(guild)
    |> Permissions.has(:manage_guild)
    |> Kernel.||({:respond, :LOC_VLOG_PERMS})
  end

  def fetch(_message, %{args: []}), do: {:ok, :show}
  def fetch(_message, %{args: ["remove" | _]}), do: {:ok, :remove}

  def fetch(%{guild_id: guild_id}, %{args: ["<#" <> rest | _]}) do
    id = String.slice(rest, 0..-2)

    case cache(:Channel, :fetch, [id]) do
      :error ->
        {:respond, {:LOC_VLOG_NO_CHANNEL, [id: id]}}

      {:ok, %{guild_id: other_guild_id}} when guild_id != other_guild_id ->
        {:respond, :LOG_VLOG_WRONG_GUILD}

      {:ok, %{type: 0, id: id}} ->
        {:ok, [id]}

      {:ok, channel} ->
        {:respond, {:LOG_VLOG_NOT_TEXT_CHANNEL, [channel: channel]}}
    end
  end

  def fetch(_message, _args) do
    {:respond, :LOG_VLOG_INVALID_ARGS}
  end

  def process(%{guild_id: guild_id}, :show) do
    case Guild.get!(guild_id, "vlog_channel_id") do
      nil ->
        :LOG_VLOG_NO_SETUP

      id ->
        {:LOG_VLOG_SETUP, [id: id]}
    end
  end

  def process(%{guild_id: guild_id}, :remove) do
    case Guild.delete!(guild_id, "vlog_channel_id") do
      1 ->
        :LOG_VLOG_REMOVED

      0 ->
        :LOG_VLOG_NOTHING_REMOVED
    end
  end

  def process(%{guild_id: guild_id}, channel_id) do
    Guild.put!(guild_id, "vlog_channel_id", channel_id)

    {:respond, {:LOC_VLOG_SET_CHANNEL, [id: channel_id]}}
  end
end
