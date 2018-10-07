defmodule Bot.Handler.Command.Music.Save do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Mutil

  import Bot.Handler.Util

  def description(),
    do: "Sents you a dm containing the currently played song, for your later use."

  def guild_only(), do: true

  def process(%{guild_id: guild_id, author: author}, _args) do
    Player
    |> lavalink(:command, [guild_id, :queue])
    |> case do
      res when is_bitstring(res) ->
        {:respond, res}

      %{queue: queue} ->
        {:value, {_user, track}} = :queue.peek(queue)

        embed =
          track
          |> Mutil.build_embed(author, "save")
          |> Map.delete(:author)

        {:ok, dm_channel} = rest(:create_dm, [author])

        case rest(:create_message, [dm_channel, [embed: embed]]) do
          {:ok, _} ->
            {:respond, "Sent you a dm."}

          {:error, _} ->
            {:respond, "I could not dm you.\nDid you disable dms or perhaps blocks me?"}
        end
    end
  end
end
