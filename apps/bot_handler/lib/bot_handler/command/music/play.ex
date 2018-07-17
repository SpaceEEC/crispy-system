defmodule Bot.Handler.Command.Music.Play do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music.{Player, Util}

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil}, _args) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(_message, []) do
    {:respond, "You have to give me a url, or something to search for."}
  end

  def inhibit(_message, _args), do: true

  def process(message, args) do
    {identifier, playlist} =
      args
      |> Enum.join(" ")
      |> String.replace(~r/<(.+)>/, "\\1")
      |> resolve_identifier()

    case fetch_tracks(identifier) do
      {:ok, []} ->
        {:respond, "Could not find anything."}

      {:ok, [track | _rest]} when not playlist ->
        queue([track], message)

      {:ok, tracks} when playlist ->
        queue(tracks, message)

      {:error, error} ->
        {:respond, Exception.format(:error, error)}
    end
  end

  defp queue(tracks, %{author: %{id: user_id} = author, channel_id: channel_id}) do
    channel = cache(Channel, :fetch!, [channel_id])
    %{id: guild_id, voice_states: voice_states} = cache(Guild, :fetch!, [channel.guild_id])
    %{id: own_id} = cache(User, :me!)

    res =
      case will_connect(voice_states, own_id, user_id) do
        voice_channel_id when is_number(voice_channel_id) ->
          if voice_channel_id != 0 do
            gateway(Bot.Gateway, :voice_state_update, [guild_id, voice_channel_id])
          end

          Player.ensure_started({guild_id, channel_id})
          tracks = Enum.map(tracks, &{author, &1})

          if Player.queue(tracks, guild_id) do
            nil
          else
            [
              embed:
                tracks
                |> List.first()
                |> elem(1)
                |> Util.build_embed(author, "add")
            ]
          end

        res when is_bitstring(res) ->
          [content: res]
      end

    unless res == nil do
      {:respond, res}
    end
  end

  defp resolve_identifier(url) do
    cond do
      Regex.match?(~r{^(https?://)?(www\.)?youtube\.com/watch\?v=.+}, url) or
        Regex.match?(~r{^(https?://)?(www\.)?soundcloud.com/.+}, url) or
          Regex.match?(~r{^(https?://)?(www\.)?twitch\.tv/.+}, url) ->
        {url, false}

      Regex.match?(~r{^(https?://)?(www\.)?youtube\.com/playlist\?list=.+}, url) ->
        {url, true}

      true ->
        {"ytsearch:#{url}", false}
    end
  end

  defp fetch_tracks(identifier) do
    res =
      HTTPoison.get(
        "localhost:2333/loadtracks",
        [{"Authorization", "12345"}],
        params: [identifier: identifier]
      )

    with {:ok, %{body: body}} <- res,
         {:ok, tracks} <- Poison.decode(body) do
      {:ok, Crux.Structs.Util.atomify(tracks)}
    else
      {:error, _error} = tuple ->
        tuple

      error ->
        {:error, error}
    end
  end

  defp will_connect(voice_states, own_id, user_id) do
    case voice_states do
      %{^user_id => %{channel_id: nil}} ->
        "You are not connected to a voice channel here."

      %{
        ^user_id => %{channel_id: user_channel_id},
        ^own_id => %{channel_id: own_channel_id}
      }
      when user_channel_id == own_channel_id ->
        0

      %{
        ^user_id => %{},
        ^own_id => %{channel_id: own_channel_id}
      }
      when not is_nil(own_channel_id) ->
        "You are in a different voice channel."

      %{^own_id => %{channel_id: own_channel_id}} when not is_nil(own_channel_id) ->
        "You are not connected to a voice channel here."

      %{^user_id => %{channel_id: channel_id}} ->
        channel_id
    end
  end
end
