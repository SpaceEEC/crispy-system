defmodule Bot.Handler.VoiceLog do
  @moduledoc false

  import Bot.Handler.Util
  alias Bot.Handler.Config.Guild
  alias Crux.Structs.{Message, VoiceState}

  @spec handle(
          old :: term(),
          new :: term()
        ) :: nil | {:ok, Message.t()} | {:error, term()}
  # same channel before and after, ignore
  def handle(%VoiceState{channel_id: channel_id}, %VoiceState{channel_id: channel_id}) do
    nil
  end

  def handle(nil, %VoiceState{} = new), do: handle(%VoiceState{channel_id: nil}, new)

  def handle(%VoiceState{channel_id: old_channel_id}, %VoiceState{
        channel_id: new_channel_id,
        user_id: user_id,
        guild_id: guild_id
      }) do
    case Guild.get(guild_id, "vlog_channel_id") do
      {:ok, nil} ->
        nil

      {:ok, channel_id} ->
        with {:ok, user} <- cache(:User, :fetch, [user_id]),
             {:ok, old_channel} <-
               if(old_channel_id, do: cache(:Channel, :fetch, [old_channel_id]), else: {:ok, nil}),
             {:ok, new_channel} <-
               if(new_channel_id, do: cache(:Channel, :fetch, [new_channel_id]), else: {:ok, nil}) do
          _handle(channel_id, user, old_channel, new_channel)
        end
    end
  end

  defp _handle(taget_id, user, nil, new_channel) do
    embed = %{
      color: 0x7CFC00,
      user: %{
        name: "#{user.username}##{user.discriminator} (#{user.id})",
        icon_url: rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{user.id}/#{user.avatar}.png"
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      description: "#{user} connected to #{new_channel} (#{new_channel.name})"
    }

    rest(:create_message, [taget_id, [embed: embed]])
  end

  defp _handle(target_id, user, old_channel, nil) do
    embed = %{
      color: 0x7CFC00,
      user: %{
        name: "#{user.username}##{user.discriminator} (#{user.id})",
        icon_url: rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{user.id}/#{user.avatar}.png"
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      description: "#{user} disconnected from #{old_channel} (#{old_channel.name})"
    }

    rest(:create_message, [target_id, [embed: embed]])
  end

  defp _handle(target_id, user, old_channel, new_channel) do
    embed = %{
      color: 0x7CFC00,
      user: %{
        name: "#{user.username}##{user.discriminator} (#{user.id})",
        icon_url: rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{user.id}/#{user.avatar}.png"
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      description:
        "#{user} moved from #{old_channel} (#{old_channel.name})" <>
          "to #{new_channel} (#{new_channel.name})"
    }

    rest(:create_message, [target_id, [embed: embed]])
  end
end
