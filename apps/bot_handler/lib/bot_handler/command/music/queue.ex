defmodule Bot.Handler.Command.Music.Queue do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music.{Player, Util}

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil}, _args) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(_message, _args), do: true

  def process(message, []), do: process(message, ["1"])

  def process(%{guild_id: guild_id}, [page | _rest]) do
    case Player.command(guild_id, :queue) do
      not_playing when is_bitstring(not_playing) ->
        {:respond, not_playing}

      %{queue: queue, position: current_time, loop: loop} ->
        total_songs = :queue.len(queue)

        queue = :queue.to_list(queue)
        [{_user, current} | _rest] = queue

        total_length =
          queue
          |> Enum.reduce(0, fn {_user, track}, acc -> track.info.length + acc end)
          |> Util.format_milliseconds()

        pages =
          ((total_songs - 1) / 10)
          |> Float.ceil()
          |> trunc()

        page =
          case Integer.parse(page) do
            {page, ""} when page < 1 ->
              1

            {page, ""} when page > pages ->
              pages

            {page, ""} ->
              page

            :error ->
              1
          end

        songs = page(queue, page)

        current_length =
          current.info.length
          |> Util.format_milliseconds()

        current_time =
          current_time
          |> Util.format_milliseconds()

        me = cache(User, :me!)

        loop = if loop, do: "**Loop is enabled**\n", else: ""

        embed = %{
          color: 0x0800FF,
          title: "Queued up Songs: #{total_songs} | Queue length: #{total_length}",
          description: """
          #{loop}**Currently playing**:
          [#{current.info.title}](#{current.info.uri})
          **Time**: (`#{current_time}` / `#{current_length}`)

          **Queue**:
          #{songs}
          """,
          thumbnail: %{
            url: Util.image_from_track(current.info)
          },
          footer: %{
            icon_url: rest(Crux.Rest.Endpoints, :cdn) <> "/avatars/#{me.id}/#{me.avatar}",
            text: "Page #{page} of #{pages}"
          },
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }

        {:respond, [embed: embed]}
    end
  end

  def page(queue, page) do
    from = (page - 1) * 10 + 1

    queue
    |> Enum.slice(from..(from + 9))
    |> Enum.with_index(from)
    |> Enum.map_join("\n", fn {{_user, track}, index} ->
      length =
        track.info.length
        |> Util.format_milliseconds()

      "`#{index}.` #{length} - [#{track.info.title}](#{track.info.uri})"
    end)
  end
end
