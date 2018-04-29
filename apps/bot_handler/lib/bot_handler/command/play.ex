defmodule Bot.Handler.Command.Play do
  @behaviour Bot.Handler.Command

  alias Crux.Structs

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def handle(message, args) do
    {:ok, fetch_message} = rest(:create_message, [message, [content: "Fetching..."]])

    {identifier, playlist} =
      args
      |> Enum.join(" ")
      |> String.replace(~r/<(.+)>/, "\\1")
      |> resolve_identifier()

    case fetch_tracks(identifier) do
      {:ok, []} ->
        rest(:edit_message, [fetch_message, [content: "Could not find anything"]])

      {:ok, [track | _rest]} when not playlist ->
        queue([track], message, fetch_message)

      {:ok, tracks} when playlist ->
        queue(tracks, message, fetch_message)

      {:error, error} ->
        rest(:edit_message, [fetch_message, [content: Exception.format(:error, error)]])
    end
  end

  defp queue(tracks, %{author: %{id: user_id} = author}, fetch_message) do
    channel = cache(Channel, :fetch!, [fetch_message.channel_id])
    guild = cache(Guild, :fetch!, [channel.guild_id])
    %{id: own_id} = cache(User, :me!)

    res =
      case will_connect(guild.voice_states, own_id, user_id) do
        channel_id when is_number(channel_id) ->
          if channel_id != 0,
            do: gateway(Bot.Gateway, :voice_state_update, [guild.id, channel_id])

          Music.Player.ensure_started({channel.guild_id, channel.id})
          tracks = Enum.map(tracks, &{author, &1})

          if Music.Player.queue(tracks, channel.guild_id) do
            rest(:delete_message, [fetch_message])
            nil
          else
            [
              embed:
                tracks
                |> List.first()
                |> elem(1)
                |> Music.Util.build_embed(author, "add")
            ]
          end

        res when is_bitstring(res) ->
          [content: res]
      end

    unless res == nil do
      rest(:edit_message, [fetch_message, res])
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
      {:ok, Structs.Util.atomify(tracks)}
    else
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
