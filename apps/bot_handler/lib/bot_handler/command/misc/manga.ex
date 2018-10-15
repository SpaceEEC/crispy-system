defmodule Bot.Handler.Command.Misc.Manga do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.AniList

  def description(), do: "tbd"

  def fetch(_message, %{args: args}) do
    Enum.join(args, " ")
    |> AniList.fetch("MANGA")
  end

  def process(message, anime) do
    case AniList.pick(message, anime, "MANGA") do
      {:respond, _} = response ->
        response

      %{} = anime ->
        embed = AniList.get_embed(anime, "MANGA")

        {:respond, [embed: embed]}
    end
  end
end
