defmodule Bot.Handler.Command.NowPlaying do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def inhibit(%{guild_id: nil} = message, _) do
    rest(:create_message, [message, [content: "That command may not be used in dms."]])
  end

  def inhibit(_message, _args), do: true

  def handle(message, _args) do
    channel = cache(Channel, :fetch!, [message.channel_id])

    Music.Player.command(channel.guild_id, :queue)
    |> send_track(channel)
  end

  def send_track(%{queue: queue, position: position, loop: loop}, channel) do
    {:value, {user, track}} = :queue.peek(queue)

    track_length =
      track.info.length
      |> Music.Util.format_milliseconds()

    track_position =
      position
      |> Music.Util.format_milliseconds()

    embed =
      Music.Util.build_embed(track, user, "np", loop)
      |> Map.update!(:description, fn description ->
        description =
          String.split(description, "\n")
          |> Enum.take(2)
          |> Enum.join("\n")

        """
        #{description}
        **Time**: (`#{track_position}`/`#{track_length}`)
        """
      end)

    rest(:create_message, [channel, [embed: embed]])
  end

  def send_track(res, channel) when is_bitstring(res) do
    rest(:create_message, [channel, [content: res]])
  end
end
