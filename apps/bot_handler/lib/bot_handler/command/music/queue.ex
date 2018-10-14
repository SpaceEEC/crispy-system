defmodule Bot.Handler.Command.Music.Queue do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.{Locale, Mutil}

  import Bot.Handler.Rpc

  require Bot.Handler.Locale

  def aliases(), do: ["q"]
  def description(), do: :LOC_DESC_QUEUE
  def guild_only(), do: true

  def fetch(_message, %{args: []}), do: {:ok, 1}

  def fetch(_message, %{args: [page | _]}) do
    page
    |> Integer.parse()
    |> case do
      {page, ""} when page < 1 ->
        1

      {page, ""} ->
        page

      :error ->
        1
    end
    |> (&{:ok, &1}).()
  end

  def process(message, %{args: []} = info), do: process(message, Map.put(info, :args, ["1"]))

  def process(%{guild_id: guild_id}, page) do
    Player
    |> lavalink(:command, [guild_id, :queue])
    |> handle_response(page)
  end

  def handle_response(not_playing, _page)
      when Locale.is_localizable(not_playing)
      when is_bitstring(not_playing) do
    {:respond, not_playing}
  end

  def handle_response(%{queue: queue, position: current_time, loop: loop}, page) do
    total_songs = :queue.len(queue)

    queue = :queue.to_list(queue)
    [{_user, current} | _rest] = queue

    total_length =
      queue
      |> Enum.reduce(0, fn {_user, track}, acc -> track.info.length + acc end)
      |> Mutil.format_milliseconds()

    pages =
      ((total_songs - 1) / 10)
      # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
      |> Float.ceil()
      |> trunc()

    page = Enum.max([page, pages])

    songs = page(queue, page)

    current_length =
      current.info.length
      |> Mutil.format_milliseconds()

    current_time =
      current_time
      |> Mutil.format_milliseconds()

    me = cache(:User, :me!)

    locale_key = if loop, do: :LOC_QUEUE_MUSIC_EMBED_LOOP, else: :LOC_QUEUE_MUSIC_EMBED

    embed = %{
      color: 0x0800FF,
      title: {:LOC_QUEUE_TITLE, [songs: total_songs, length: total_length]},
      description:
        {locale_key,
         [
           title: current.info.title,
           uri: current.info.uri,
           current: current_time,
           length: current_length,
           songs: songs
         ]},
      thumbnail: %{
        url: Mutil.image_from_track(current.info)
      },
      footer: %{
        icon_url: rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{me.id}/#{me.avatar}",
        text: {:LOC_QUEUE_FOOTER, [page: page, pages: pages]}
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    {:respond, [embed: embed]}
  end

  def page(queue, page) do
    from = (page - 1) * 10 + 1

    queue
    |> Enum.slice(from..(from + 9))
    |> Enum.with_index(from)
    |> Enum.map_join("\n", fn {{_user, track}, index} ->
      length =
        track.info.length
        |> Mutil.format_milliseconds()

      "`#{index}.` #{length} - [#{track.info.title}](#{track.info.uri})"
    end)
  end
end
