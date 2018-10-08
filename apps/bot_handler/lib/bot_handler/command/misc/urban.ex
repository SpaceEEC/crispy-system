defmodule Bot.Handler.Command.Misc.Urban do
  @moduledoc false

  alias Bot.Handler.Rest

  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  @urban_base "urbandictionary.com/v0/define"
  @urban_api "https://api." <> @urban_base <> "?term="
  @urban_web "https://" <> @urban_base <> ".php?term="

  def usages(), do: ["[\"-\"Number] <...Term>"]
  def examples(), do: ["test", "-2 test", "-10 test"]
  def description(), do: :LOC_DESC_URBAN

  def fetch(_message, %{args: []}) do
    {:respond, :LOC_URBAN_NO_QUERY}
  end

  def fetch(message, %{args: ["-" <> number | rest]} = info) do
    case Integer.parse(number) do
      {number, ""} ->
        number = Enum.max([1, number])
        fetch(message, Map.put(info, :args, [number | rest]))

      _ ->
        fetch(message, Map.put(info, :args, [1 | rest]))
    end
  end

  def fetch(_message, %{args: [number | args]}) when is_integer(number) do
    search =
      args
      |> Enum.join("+")
      |> URI.encode()

    res = Rest.get(@urban_api <> search)

    {:ok, {res, number, search}}
  end

  def fetch(message, info), do: fetch(message, Map.update!(info, :args, &[1 | &1]))

  def process(message, {{:ok, %{body: %{"list" => []}}}, _number, search}) do
    embed = %{
      color: 0x1D2439,
      author: %{
        name: "Urbandictionary",
        url: "http://www.urbandictionary.com/",
        icon_url: "http://www.urbandictionary.com/favicon.ico"
      },
      # thumbnail: %{url: ""},
      description: {:LOC_NOTHING_FOUND_URL, [url: @urban_web <> search]},
      footer: %{
        text: message.content,
        icon_url: rest(CDN, :user_avatar, [message.author])
      }
    }

    {:respond, [embed: embed]}
  end

  def process(message, {{:ok, %{body: %{"list" => results}}}, number, search})
      when is_list(results) do
    [%{"example" => example, "definition" => definition}, number] =
      case Enum.at(results, number - 1) do
        nil ->
          [List.last(results), Enum.count(results)]

        result ->
          [result, number]
      end

    search = search |> URI.decode() |> String.split("+") |> Enum.join(" ")

    embed = %{
      color: 0x1D2439,
      author: %{
        name: "Urbandictionary",
        # icon_url: "",
        url: "http://www.urbandictionary.com/"
      },
      # thumbnail: %{url: ""},
      title: "#{search} [#{number}/#{Enum.count(results)}]",
      footer: %{
        text:
          {:LOC_URBAN_FOOTER,
           [content: message.content, number: number, total: Enum.count(results)]},
        icon_url: rest(Crux.Rest.CDN, :user_avatar, [message.author, [size: 32]])
      }
    }

    example_fields = chunk(:LOC_URBAN_EXAMPLE, example)
    definition_fields = chunk(:LOC_URBAN_DEFINITION, definition)

    embed = Map.put(embed, :fields, definition_fields ++ example_fields)

    {:respond, [embed: embed]}
  end

  def process(message, {{:error, _error}, _number, search}) do
    embed = %{
      color: 0x1D2439,
      author: %{
        name: "Urbandictionary",
        url: "http://www.urbandictionary.com/",
        icon_url: "http://www.urbandictionary.com/favicon.ico"
      },
      # thumbnail: %{url: ""},
      description: {:LOC_URBAN_ERROR, [url: @urban_web <> search]},
      footer: %{
        text: message.content,
        icon_url: rest(CDN, :user_avatar, [message.author])
      }
    }

    {:respond, [embed: embed]}
  end

  def chunk(_title, nil), do: []

  def chunk(title, text) do
    [[first | _] | rest] = Regex.scan(~r/(.|[\r\n]){1,1024}/, text)

    [
      %{
        name: title,
        value: first
      }
      | for [chunk | _] <- rest do
          %{name: "\u200b", value: chunk}
        end
    ]
  end
end
