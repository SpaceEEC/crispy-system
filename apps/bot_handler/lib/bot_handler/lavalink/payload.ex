defmodule Bot.Handler.Lavalink.Payload do
  def play(track, guild_id, start_end \\ []) do
    Map.new(start_end)
    |> Map.put("track", track)
    |> finalize("play", guild_id)
  end

  def stop(guild_id), do: finalize(%{}, "stop", guild_id)

  def pause(pause, guild_id) do
    %{"pause" => pause}
    |> finalize("pause", guild_id)
  end

  def seek(time, guild_id) do
    %{"position" => time}
    |> finalize("seek", guild_id)
  end

  def volume(volume, guild_id) do
    %{"volume" => volume}
    |> finalize("volume", guild_id)
  end

  defp finalize(data, op, guild_id) do
    %{
      "op" => op,
      "guildId" => Integer.to_string(guild_id)
    }
    |> Map.merge(data)
  end
end
