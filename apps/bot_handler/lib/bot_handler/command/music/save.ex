defmodule Bot.Handler.Command.Music.Save do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.{Locale, Mutil}

  import Bot.Handler.Rpc

  require Bot.Handler.Locale

  def description(), do: :LOC_DESC_SAVE

  def guild_only(), do: true

  def process(%{guild_id: guild_id, author: author}, _args) do
    Player
    |> lavalink(:command, [guild_id, :queue])
    |> case do
      res
      when Locale.is_localizable(res)
      when is_bitstring(res) ->
        {:respond, res}

      %{queue: queue} ->
        {:value, {_user, track}} = :queue.peek(queue)

        locale = Locale.fetch!(guild_id)

        embed =
          track
          |> Mutil.build_embed(author, "save")
          |> Map.delete(:author)
          |> Locale.localize_embed(locale)

        {:ok, dm_channel} = rest(:create_dm, [author])

        case rest(:create_message, [dm_channel, [embed: embed]]) do
          {:ok, _} ->
            {:respond, :LOC_SENT_DM}

          {:error, _} ->
            {:respond, :LOC_FAILED_DM}
        end
    end
  end
end
