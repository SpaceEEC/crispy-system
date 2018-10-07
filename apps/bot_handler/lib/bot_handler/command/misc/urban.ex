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
  def description(), do: "Displays the urban definition of a term."

  def fetch(_message, []) do
    {:respond, "You need to tell me what you want to look up."}
  end

  def fetch(message, ["-" <> number | rest]) do
    case Integer.parse(number) do
      {number, ""} ->
        number = Enum.max([1, number])
        fetch(message, [number | rest])

      _ ->
        fetch(message, [1 | rest])
    end
  end

  def fetch(_message, [number | args]) when is_integer(number) do
    search =
      args
      |> Enum.join("+")
      |> URI.encode()

    res = Rest.get(@urban_api <> search)

    {:ok, {res, number, search}}
  end

  def fetch(message, args), do: fetch(message, [1 | args])

  def process(message, {{:ok, %{body: %{"list" => []}}}, _number, search}) do
    embed = %{
      color: 0x1D2439,
      author: %{
        name: "Urbandictionary",
        url: "http://www.urbandictionary.com/",
        icon_url: "http://www.urbandictionary.com/favicon.ico"
      },
      thumbnail: %{url: "https://a.safe.moe/7BZzg.png"},
      description: """
      Could not find anything.
      Maybe made a typo? [Search](#{@urban_web}#{search})
      """,
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
        icon_url: "https://a.safe.moe/7BZzg.png",
        url: "http://www.urbandictionary.com/"
      },
      thumbnail: %{
        url: "https://a.safe.moe/7BZzg.png"
      },
      title: "#{search} [#{number}/#{Enum.count(results)}]",
      footer: %{
        text: "#{message.content} | Definition #{number} out of #{Enum.count(results)}",
        icon_url: rest(Crux.Rest.CDN, :user_avatar, [message.author, [size: 32]])
      }
    }

    example_fields =
      if example do
        [[example_first | _] | example_rest] = Regex.scan(~r/(.|[\r\n]){1,1024}/, example)

        [
          %{
            name: "❯ Example",
            value: example_first
          }
          | for [chunk | _] <- example_rest do
              %{
                name: "\u200b",
                value: chunk
              }
            end
        ]
      else
        []
      end

    [[definition_first | _] | definition_rest] = Regex.scan(~r/(.|[\r\n]){1,1024}/, definition)

    definition_fields = [
      %{
        name: "❯  Definition",
        value: definition_first
      }
      | for [chunk | _] <- definition_rest do
          %{
            name: "\u200b",
            value: chunk
          }
        end
    ]

    embed =
      embed
      |> Map.put(:fields, definition_fields ++ example_fields)

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
      thumbnail: %{url: "https://a.safe.moe/7BZzg.png"},
      description: """
      An error occurred while fetching. [Search](#{@urban_web}#{search})
      """,
      footer: %{
        text: message.content,
        icon_url: rest(CDN, :user_avatar, [message.author])
      }
    }

    {:respond, [embed: embed]}
  end
end
