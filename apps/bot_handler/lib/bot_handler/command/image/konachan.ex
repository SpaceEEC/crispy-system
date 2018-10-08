defmodule Bot.Handler.Command.Image.Konachan do
  @moduledoc false

  @behaviour Bot.Handler.Command

  @konachan_post "https://konachan.com/post"

  alias Bot.Handler.Rest

  def usages(), do: ["<...Tags>"]
  def examples(), do: ["komeiji_satori", "touhou long_sleeves"]

  def description(), do: :LOC_DESC_KONACHAN

  def fetch(_message, %{args: args}) when length(args) <= 5 do
    tags =
      args
      |> Enum.join(" ")
      |> URI.encode()

    res = Rest.get("#{@konachan_post}.json?tags=#{tags}+rating:s&limit=100")
    {:ok, {res, tags}}
  end

  def fetch(_message, _args) do
    {:respond, {:LOC_IMAGE_MAX_TAGS, [max: 5]}}
  end

  def process(_message, {:ok, %{body: []}, tags}) do
    data = [
      embed: %{
        title: :LOC_NO_RESULTS,
        description: {:LOC_NOTHING_FOUND_URL, [url: "#{@konachan_post}?tags=#{tags}"]}
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
    {:respond, :LOC_IMAGE_ERROR}
  end
end
