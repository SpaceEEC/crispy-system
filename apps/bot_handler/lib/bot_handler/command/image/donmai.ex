defmodule Bot.Handler.Command.Image.Donmai do
  @moduledoc false

  @behaviour Bot.Handler.Command

  @donmai_posts "https://safebooru.donmai.us/posts"

  alias Bot.Handler.Rest

  def usages(), do: ["<...Tags>"]
  def examples(), do: ["komeiji_satori", "touhou long_sleeves"]

  def description(), do: :LOC_DESC_DONMAI

  def fetch(_message, %{args: args}) when length(args) <= 2 do
    tags =
      args
      |> Enum.join(" ")
      |> URI.encode()

    res = Rest.get("#{@donmai_posts}.json?limit=1&random=true&tags=#{tags}")
    {:ok, {res, tags}}
  end

  def fetch(_message, _args) do
    {:respond, {:LOC_IMAGE_MAX_TAGS, [max: 2]}}
  end

  def process(_message, {{:ok, %{body: []}}, tags}) do
    data = [
      embed: %{
        title: :LOC_NO_RESULTS,
        description: {:LOC_NOTHING_FOUND_URL, [url: "#{@donmai_posts}?tags=#{tags}"]}
      }
    ]

    {:respond, data}
  end

  def process(_message, {{:ok, %{body: [%{"file_url" => url, "id" => id}]}}, _tags}) do
    data = [
      embed: %{
        description: "[Source](#{@donmai_posts}/#{id})",
        image: %{url: url}
      }
    ]

    {:respond, data}
  end

  def process(_message, {{:error, _err}, _tags}) do
    {:respond, :LOC_IMAGE_ERROR}
  end
end
