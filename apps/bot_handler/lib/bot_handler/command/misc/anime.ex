defmodule Bot.Handler.Command.Misc.Anime do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.AniList

  def description(), do: :LOC_DESC_ANIME

  def fetch(_message, %{args: args}) do
    args
    |> Enum.join(" ")
    |> AniList.fetch("ANIME")
  end

  def process(message, anime) do
    case AniList.pick(message, anime, "ANIME") do
      {:respond, _} = response ->
        response

      %{} = anime ->
        embed = AniList.get_embed(anime, "ANIME")

        {:respond, [embed: embed]}
    end
  end
end
