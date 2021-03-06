defmodule Bot.Handler.Command.Music.Play do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.{Locale, Util}

  import Bot.Handler.Rpc

  require Bot.Handler.Locale

  def description(), do: :LOC_DESC_PLAY

  def examples(),
    do: [
      "Maribou State - Tongue (feat. Holly Walker)",
      "https://www.youtube.com/watch?v=fMZpb9vfiOM",
      "https://www.youtube.com/playlist?list=PLDfKAXSi6kUafKlwAurWST8zb4-Zy1JcU"
    ]

  def usages(), do: ["<...Search>", "<Video URL>", "<Playlist URL>"]
  def guild_only(), do: true

  def inhibit(_, _) do
    Node.ping(lavalink()) == :pong || {:respond, {:LOC_NODE_OFFLINE, [node: lavalink()]}}
  end

  def fetch(_message, %{args: []}) do
    {:respond, :LOC_MUSIC_NO_QUERY}
  end

  def fetch(_message, %{args: args}) do
    query =
      args
      |> Enum.join(" ")
      |> String.replace(~r/<(.+)>/, "\\1")

    {identifier, playlist} = lavalink(Rest, :resolve_identifier, [query])

    case lavalink(Rest, :fetch_tracks, [identifier]) do
      {:ok, []} ->
        {:respond, :LOC_NOTHING_FOUND}

      {:ok, tracks} when playlist ->
        {:ok, tracks}

      {:ok, [track | _rest]} ->
        {:ok, [track]}

      {:error, error} ->
        {:respond, Exception.format(:error, error)}
    end
  end

  def process(%{author: %{id: user_id} = author, channel_id: channel_id}, tracks) do
    channel = cache(:Channel, :fetch!, [channel_id])
    %{id: guild_id, voice_states: voice_states} = cache(:Guild, :fetch!, [channel.guild_id])

    case Util.will_connect(voice_states, user_id) do
      voice_channel_id when is_number(voice_channel_id) ->
        unless voice_channel_id == 0 do
          gateway(Bot.Gateway, :voice_state_update, [guild_id, voice_channel_id])
        end

        lavalink(Player, :ensure_started, [{guild_id, channel_id}])
        tracks = Enum.map(tracks, &{author, &1})

        if lavalink(Player, :queue, [tracks, guild_id]) do
          nil
        else
          {:respond,
           [
             embed:
               tracks
               |> List.first()
               |> elem(1)
               |> Util.build_embed(author, "add")
           ]}
        end

      res
      when Locale.is_localizable(res)
      when is_bitstring(res) ->
        {:respond, res}
    end
  end
end
