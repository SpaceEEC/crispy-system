defmodule Bot.Handler.Command.Music.NowPlaying do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.{Locale, Util}

  import Bot.Handler.Rpc

  require Bot.Handler.Locale

  def aliases(), do: ["np"]
  def description(), do: :LOC_DESC_NP
  def guild_only(), do: true

  def inhibit(_, _) do
    Node.ping(lavalink()) == :pong || {:respond, {:LOC_NODE_OFFLINE, [node: lavalink()]}}
  end

  def fetch(%{channel_id: channel_id}, _args) do
    {:ok, cache(:Channel, :fetch!, [channel_id])}
  end

  def process(_message, %{guild_id: guild_id}) do
    Player
    |> lavalink(:command, [guild_id, :queue])
    |> handle_response()
  end

  defp handle_response(response)
       when Locale.is_localizable(response)
       when is_bitstring(response) do
    {:respond, response}
  end

  defp handle_response(%{queue: queue, position: position, loop: loop}) do
    {:value, {user, track}} = :queue.peek(queue)

    track_length =
      track.info.length
      |> Util.format_milliseconds()

    tmp =
      position
      |> Kernel./(track.info.length)
      |> Kernel.*(10)
      |> Float.ceil()
      |> trunc()

    played_bars = String.pad_leading("", tmp, "▬")

    track_position =
      position
      |> Util.format_milliseconds()

    unplayed_bars = String.pad_leading("", 10 - tmp, "▬")

    key = if(loop, do: :LOC_NP_EMBED_LOOP, else: :LOC_NP_EMBED)

    embed =
      track
      |> Util.build_embed(user, "np", loop)
      |> Map.update!(:description, fn {_key, args} ->
        args =
          Keyword.merge(args,
            played_bars: played_bars,
            unplayed_bars: unplayed_bars,
            position: track_position,
            length: track_length
          )

        {key, args}
      end)

    {:respond, [embed: embed]}
  end
end
