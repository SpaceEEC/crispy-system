defmodule Bot.Handler.Command.Image.Konachan do
  @moduledoc false

  @behaviour Bot.Handler.Command

  @konachan_post "https://konachan.com/post"

  alias Bot.Handler.Rest

  def usages(), do: ["<...Tags>"]
  def examples(), do: ["komeiji_satori", "touhou long_sleeves"]

  def description(),
    do:
      "Fetches a random picture from https://konachan.net/, optionally with tags to search with."

  def fetch(_message, args) when length(args) <= 5 do
    tags =
      args
      |> Enum.join(" ")
      |> URI.encode()

    res = Rest.get("#{@konachan_post}.json?tags=#{tags}+rating:s&limit=100")
    {:ok, {res, tags}}
  end

  def fetch(_message, _args) do
    {:respond, "The maximum amount of tags you can specify is 5."}
  end

  def process(_message, {:ok, %{body: []}, tags}) do
    data = [
      embed: %{
        title: "No results",
        description:
          "Could not find anything.\nMaybe made a typo? [Search](#{@konachan_post}?tags=#{tags})"
      }
    ]

    {:respond, data}
  end

  def process(_message, {{:ok, %{body: images}}, _tags}) do
    %{"sample_url" => url, "id" => id} = Enum.random(images)

    data = [
      embed: %{
        description: "[Source](#{@konachan_post}/show/#{id})",
        image: %{url: url}
      }
    ]

    {:respond, data}
  end

  def process(_message, {{:error, _error}, _tags}) do
    {:respond, "An error occured while fetching an image."}
  end
end
