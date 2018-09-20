defmodule Bot.Handler.Command.Music.Save do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Music

  import Bot.Handler.Util

  def description(),
    do: "Sents you a dm containing the currently played song, for your later use."

  def guild_only(), do: true

  def process(message, _args) do
    Music.Player.command(message.guild_id, :queue)
    |> case do
      res when is_bitstring(res) ->
        {:respond, res}

      %{queue: queue} ->
        {:value, {_user, track}} = :queue.peek(queue)

        embed =
          Music.Util.build_embed(track, message.author, "save")
          |> Map.delete(:author)

        {:ok, dm_channel} = rest(:create_dm, [message.author])

        case rest(:create_message, [dm_channel, [embed: embed]]) do
          {:ok, _} ->
            {:respond, "Sent you a dm."}

          {:error, _} ->
            {:respond, "I could not dm you.\nDid you disable dms or perhaps blocks me?"}
        end
    end
  end
end
