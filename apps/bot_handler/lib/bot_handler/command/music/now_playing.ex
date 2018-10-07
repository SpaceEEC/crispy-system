defmodule Bot.Handler.Command.Music.NowPlaying do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Mutil

  import Bot.Handler.Util

  def aliases(), do: ["np"]
  def description(), do: "Displays the currently played song."
  def guild_only(), do: true

  def fetch(%{channel_id: channel_id}, _args) do
    channel = cache(:Channel, :fetch!, [channel_id])

    {:ok, channel}
  end

  def process(_message, %{guild_id: guild_id}) do
    Player
    |> lavalink(:command, [guild_id, :queue])
    |> case do
      res when is_bitstring(res) ->
        {:respond, res}

      %{queue: queue, position: position, loop: loop} ->
        {:value, {user, track}} = :queue.peek(queue)

        track_length =
          track.info.length
          |> Mutil.format_milliseconds()

        # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
        tmp = (position / track.info.length * 10) |> Float.ceil() |> trunc()
        played_bars = String.pad_leading("", tmp, "▬")

        track_position =
          position
          |> Mutil.format_milliseconds()

        unplayed_bars = String.pad_leading("", 10 - tmp, "▬")

        embed =
          track
          |> Mutil.build_embed(user, "np", loop)
          |> Map.update!(:description, fn description ->
            description =
              description
              |> String.split("Length:")
              |> List.first()

            "#{description}\n **Progress**: " <>
              "**[#{played_bars}](https://crux.randomly.space/)#{unplayed_bars}** " <>
              " (`#{track_position}`/`#{track_length}`)"
          end)

        {:respond, [embed: embed]}
    end
  end
end
