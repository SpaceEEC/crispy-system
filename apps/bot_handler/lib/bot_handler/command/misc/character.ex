defmodule Bot.Handler.Command.Misc.Character do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.AniList

  def aliases(), do: ["char"]
  def description(), do: :LOC_DESC_CHARACTER

  def fetch(_message, %{args: args}) do
    Enum.join(args, " ")
    |> AniList.fetch("CHARACTER")
  end

  def process(message, chars) do
    case AniList.pick(message, chars, "CHARACTER") do
      {:respond, _} = response ->
        response

      %{} = character ->
        embed = AniList.get_embed(character, "CHARACTER")

        {:respond, [embed: embed]}
    end
  end
end
