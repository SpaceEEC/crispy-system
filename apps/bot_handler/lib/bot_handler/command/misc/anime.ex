defmodule Bot.Handler.Command.Misc.Anime do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.AniList

  def description(), do: "tbd"

  def fetch(_message, %{args: args}) do
    Enum.join(args, " ")
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
