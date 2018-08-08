defmodule Bot.Handler.Lavalink.Payload do
  @spec play(
          track :: String.t(),
          guild_id :: Crux.Rest.snoflake(),
          start_end ::
            [{:startTime, Integer.t()} | {:endTime, Integer.t()}]
            | %{optional(:startTime) => Integer.t(), optional(:endTime) => Integer.t()}
        ) :: map()
  def play(track, guild_id, start_end \\ []) do
    Map.new(start_end)
    |> Map.put("track", track)
    |> finalize("play", guild_id)
  end

  @spec stop(guild_id :: String.t()) :: map()
  def stop(guild_id), do: finalize(%{}, "stop", guild_id)

  @spec pause(paused :: boolean(), guild_id :: String.t()) :: map()
  def pause(paused, guild_id) do
    %{"pause" => paused}
    |> finalize("pause", guild_id)
  end

  @spec seek(time_millis :: Integer.t(), guild_id :: String.t()) :: map()
  def seek(time_millis, guild_id) do
    %{"position" => time_millis}
    |> finalize("seek", guild_id)
  end

  @spec volume(volume :: Integer.t(), guild_id :: String.t()) :: map()
  def volume(volume, guild_id) do
    %{"volume" => volume}
    |> finalize("volume", guild_id)
  end

  @spec voice_update(event :: map(), session_id :: String.t(), guild_id :: String.t()) :: map()
  def voice_update(event, session_id, guild_id) do
    %{sessionId: session_id, event: event}
    |> finalize("voiceUpdate", guild_id)
  end

  @spec finalize(data :: map(), op :: String.t(), guild_id :: String.t()) :: map()
  defp finalize(data, op, guild_id) do
    %{
      "op" => op,
      "guildId" => to_string(guild_id)
    }
    |> Map.merge(data)
  end
end
