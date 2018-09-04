defmodule Bot.Handler.VoiceLog do
  import Bot.Handler.Util

  # same channel before and after, ignore
  def handle(%{channel_id: channel_id}, %{channel_id: channel_id}), do: nil

  def handle(%{channel_id: nil}, %{channel_id: new_channel_id, user_id: user_id}) do
    with {:ok, user} <- cache(User, :fetch, [user_id]),
         {:ok, new_channel} <- cache(Channel, :fetch, [new_channel_id]) do
      embed = %{
        color: 0x7CFC00,
        user: %{
          name: "#{user.username}##{user.discriminator} (#{user.id})",
          icon_url:
            rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{user.id}/#{user.avatar}.png"
        },
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        description: "#{user} connected to #{new_channel} (#{new_channel.name})"
      }

      rest(:create_message, [242_663_102_590_615_552, [embed: embed]])
    end
  end

  def handle(%{channel_id: old_channel_id}, %{channel_id: nil, user_id: user_id}) do
    with {:ok, user} <- cache(User, :fetch, [user_id]),
         {:ok, old_channel} <- cache(Channel, :fetch, [old_channel_id]) do
      embed = %{
        color: 0x7CFC00,
        user: %{
          name: "#{user.username}##{user.discriminator} (#{user.id})",
          icon_url:
            rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{user.id}/#{user.avatar}.png"
        },
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        description: "#{user} disconnected from #{old_channel} (#{old_channel.name})"
      }

      rest(:create_message, [242_663_102_590_615_552, [embed: embed]])
    end
  end

  def handle(%{channel_id: old_channel_id}, %{channel_id: new_channel_id, user_id: user_id}) do
    with {:ok, user} <- cache(User, :fetch, [user_id]),
         {:ok, old_channel} <- cache(Channel, :fetch, [old_channel_id]),
         {:ok, new_channel} <- cache(Channel, :fetch, [new_channel_id]) do
      embed = %{
        color: 0x7CFC00,
        user: %{
          name: "#{user.username}##{user.discriminator} (#{user.id})",
          icon_url:
            rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{user.id}/#{user.avatar}.png"
        },
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        description:
          "#{user} moved from #{old_channel} (#{old_channel.name})" <>
            "to #{new_channel} (#{new_channel.name})"
      }

      rest(:create_message, [242_663_102_590_615_552, [embed: embed]])
    end
  end
end
