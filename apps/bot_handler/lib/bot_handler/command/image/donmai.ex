defmodule Bot.Handler.Command.Image.Donmai do
  @behaviour Bot.Handler.Command

  @donmai_posts "https://safebooru.donmai.us/posts"

  def fetch(_message, args) when length(args) <= 2 do
    tags =
      args
      |> Enum.join(" ")
      |> URI.encode()

    res = Bot.Handler.Rest.get("#{@donmai_posts}.json?limit=1&random=true&tags=#{tags}")
    {:ok, {res, tags}}
  end

  def fetch(_message, _args) do
    {:respond, "The maximum amount of tags you can specify is 2."}
  end

  def process(_message, {{:ok, %{body: []}}, tags}) do
    data = [
      embed: %{
        title: "No results",
        description:
          "Could not find anything.\nMaybe made a typo? [Search](#{@donmai_posts}?tags=#{tags})"
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
    {:respond, "An error occured while fetching an image."}
  end
end
