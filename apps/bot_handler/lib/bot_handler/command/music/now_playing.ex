defmodule Bot.Handler.Command.Music.NowPlaying do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music.{Player, Util}

  import Bot.Handler.Util

  def description(), do: "Displays the currently played song."

  def aliases(), do: ["np"]

  def inhibit(%{guild_id: nil}, _) do
    {:respond, "That command may not be used in dms."}
  end

  def inhibit(_message, _args), do: true

  def fetch(%{channel_id: channel_id}, _args) do
    channel = cache(:Channel, :fetch!, [channel_id])

    {:ok, channel}
  end

  def process(_message, channel) do
    Player.command(channel.guild_id, :queue)
    |> case do
      res when is_bitstring(res) ->
        {:respond, res}

      %{queue: queue, position: position, loop: loop} ->
        {:value, {user, track}} = :queue.peek(queue)

        track_length =
          track.info.length
          |> Util.format_milliseconds()

        tmp = (position / track.info.length * 10) |> Float.ceil() |> trunc()
        played_bars = String.pad_leading("", tmp, "▬")

        track_position =
          position
          |> Util.format_milliseconds()

        unplayed_bars = String.pad_leading("", 10 - tmp, "▬")

        embed =
          Util.build_embed(track, user, "np", loop)
          |> Map.update!(:description, fn description ->
            description =
              String.split(description, "Length:")
              |> List.first()

            "#{description}\n **Progress**: " <>
              "**[#{played_bars}](https://crux.randomly.space/)#{unplayed_bars}** " <>
              " (`#{track_position}`/`#{track_length}`)"
          end)

        {:respond, [embed: embed]}
    end
  end
end
