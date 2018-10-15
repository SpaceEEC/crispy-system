defmodule Bot.Handler.AniList do
  @media_body %{
    query: """
    query ($query: String, $type: MediaType) {
      result: Page(page: 1, perPage: 20) {
        results: media(search: $query, type: $type) {
          title {
            romaji
            english
            native
          }
          # season
          genres
          average_score: averageScore
          mean_score: meanScore
          volumes
          chapters
          episodes
          start_date: startDate {
            year
            month
            day
          }
          status
          end_date: endDate {
            year
            month
            day
          }
          image: coverImage {
            large
          }
          description(asHtml: false)
          source
          site_url: siteUrl
        }
      }
    }
    """,
    variables: %{
      query: nil,
      type: nil
    }
  }

  @char_body %{
    query: """
    query ($query: String) {
      result: Page(page: 1, perPage: 20) {
        results: characters(search: $query) {
          # id
          name {
            first
            last
            native
            alternative
          }
          image {
            large
          }
          description(asHtml: false)
          site_url: site_url
        }
      }
    }
    """,
    variables: %{
      query: nil
    }
  }

  @url "https://graphql.anilist.co"

  alias Bot.Handler.{Awaiter, Embed, Rest}
  import Bot.Handler.Rpc

  def fetch("", _type), do: {:respond, "no query"}

  def fetch(query, type) when is_binary(query) and type in ["ANIME", "MANGA"] do
    body =
      @media_body
      |> put_in([:variables, :query], query)
      |> put_in([:variables, :type], type)

    @url
    |> Rest.post!(body)
    |> handle_response()
  end

  def fetch(query, "CHARACTER") when is_binary(query) do
    body =
      @char_body
      |> put_in([:variables, :query], query)

    @url
    |> Rest.post!(body)
    |> handle_response()
  end

  defp handle_response(%{body: %{"errors" => errors}}) when not is_nil(errors) do
    # TODO: Might be worth to improve this
    raise inspect(errors)
  end

  defp handle_response(%{body: %{"data" => %{"result" => %{"results" => []}}}}) do
    {:respond, "nothing found"}
  end

  defp handle_response(%{body: %{"data" => %{"result" => %{"results" => results}}}}) do
    {:ok, results}
  end

  def pick(_message, [], _type), do: {:respond, "nothing found"}
  def pick(_message, [element], _type), do: element

  def pick(message, elements, type) when type in ["ANIME", "CHARACTER", "MANGA"] do
    length = elements |> Enum.count() |> to_string() |> String.length()

    description =
      elements
      |> Enum.with_index()
      |> Enum.map_join(
        "\n",
        fn
          {%{"name" => %{"first" => first_name, "last" => last_name}}, i} ->
            i = i |> Kernel.+(1) |> to_string() |> String.pad_trailing(length, " ")
            "`#{i}` - #{first_name || ""} #{last_name || ""}"

          {%{"title" => %{"english" => title_english, "romaji" => title_romaji}}, i} ->
            i = i |> Kernel.+(1) |> to_string() |> String.pad_trailing(length, " ")
            title = not_empty(title_english, title_romaji)
            "`#{i}` - #{title}"
        end
      )
      |> String.slice(0..2023)

    embed = %{
      title: "I found more than one #{type |> String.downcase()}",
      description: description,
      fields: [
        %{
          name: "Notice",
          value: """
          For which #{type |> String.downcase()} would you like to see additional information?
          Please respond with the number of the entry you would like to see, for example `3`.

          To cancel this prompt respond with `cancel` or wait `30` seconds.
          """
        }
      ]
    }

    prompt = rest(:create_message!, [message, [embed: embed]])

    response =
      Awaiter.await(
        :MESSAGE_CREATE,
        fn %{author: %{id: id}} -> id == message.author.id end,
        30_000
      )

    rest(:delete_message, [prompt])

    unless response == :timeout do
      rest(:delete_message, [response])

      with {number, _} when number > 0 <- Integer.parse(response.content),
           char when not is_nil(char) <- Enum.at(elements, number - 1) do
        char
      else
        {_number, _rest} ->
          {:respond, "not a positive number"}

        :error ->
          {:respond, "not a number"}

        nil ->
          {:respond, "no such entry"}
      end
    end
  end

  defp not_empty(nil, other), do: other
  defp not_empty("", other), do: other

  defp not_empty(str, other) do
    case String.trim(str) do
      "" -> other
      trimmed -> trimmed
    end
  end

  def get_embed(
        %{
          "name" => %{
            "first" => first_name,
            "last" => last_name,
            "native" => native_name,
            "alternative" => alternative_names
          },
          "image" => %{"large" => large_image},
          "description" => description,
          "site_url" => site_url
        },
        "CHARACTER"
      ) do
    embed = %{
      color: 0x02a8fe,
      thumbnail: %{
        url: large_image
      },
      url: site_url,
      title: "\u200b#{first_name} #{last_name}",
      description: native_name |> Kernel.||("") |> Embed.html_entity_to_utf8()
    }

    embed =
      case alternative_names do
        nil ->
          embed

        [] ->
          embed

        [""] ->
          embed

        _ ->
          field = %{
            name: "Aliases:",
            value: alternative_names |> Enum.map(&Embed.html_entity_to_utf8/1) |> Enum.join(", "),
            inline: true
          }

          Map.update(embed, :fields, [field], &[field | &1])
      end

    rest = Embed.chunk("Description", description)

    embed = Map.update(embed, :fields, rest, &(&1 ++ rest))

    embed
  end

  def get_embed(
        %{
          "title" => titles,
          # "season" => season,
          "genres" => genres,
          "average_score" => average_score,
          "mean_score" => mean_score,
          "volumes" => volumes,
          "chapters" => chapters,
          "episodes" => episodes,
          "start_date" => start_date,
          "status" => status,
          "end_date" => end_date,
          "image" => %{
            "large" => large_image
          },
          "description" => description,
          "source" => source,
          "site_url" => site_url
        },
        type
      )
      when type in ["ANIME", "MANGA"] do
    [title, embed_description] =
      titles
      |> Map.values()
      |> Enum.uniq()
      |> Enum.flat_map(fn
        nil ->
          []

        "" ->
          []

        title ->
          case String.trim(title) do
            "" -> []
            trimmed -> [trimmed]
          end
      end)
      |> case do
        [title] -> [title, nil]
        [title | description] -> [title, Enum.join(description, "\n")]
      end

    genres =
      genres
      |> Enum.chunk_every(3)
      |> Enum.map_join("\n", &Enum.join(&1, ", "))

    fields =
      [
        %{
          name: "Rating | Type",
          value: "#{average_score || mean_score || "??"} | #{type |> String.capitalize()}",
          inline: true
        },
        %{
          name: "Genres",
          value: not_empty(genres, "Not specified"),
          inline: true
        }
      ]
      |> add_counts(type, episodes, chapters, volumes)
      |> add_timestamps(start_date, end_date, status)
      |> Embed.chunk("Description", not_empty(description, "??"))
      |> add_status(type, status)
      |> add_source(type, source)
      |> Enum.reverse()

    %{
      thumbnail: %{url: large_image},
      url: site_url,
      title: title,
      description: embed_description,
      fields: fields,
      color: 0x02a8fe
    }
  end

  defp add_source(fields, "ANIME", source) do
    value =
      case source do
        "" ->
          "??"

        nil ->
          "??"

        _source ->
          source
          |> String.split("_")
          |> Enum.map_join(" ", &String.capitalize/1)
      end

    [
      %{
        name: "Origin",
        value: value,
        inline: true
      }
      | fields
    ]
  end

  defp add_source(fields, _type, _source), do: fields

  defp add_status(fields, type, status) do
    name =
      case type do
        "ANIME" -> "Airing Status"
        "MANGA" -> "Publishing Stauts"
      end

    value =
      case status do
        "" ->
          "??"

        nil ->
          "??"

        _status ->
          status
          |> String.split("_")
          |> Enum.map_join(" ", &String.capitalize/1)
      end

    [
      %{
        name: name,
        value: value,
        inline: true
      }
      | fields
    ]
  end

  defp add_counts(fields, "ANIME", episodes, _chapters, _volumes) do
    [
      %{
        name: "Episodes",
        value: episodes || "??",
        inline: true
      }
      | fields
    ]
  end

  defp add_counts(fields, "MANGA", _episodes, chapters, volumes) do
    [
      %{
        name: "Chapters | Volumes",
        value: "#{chapters || "??"} | #{volumes || "??"}",
        inline: true
      }
      | fields
    ]
  end

  defp add_timestamps(fields, nil, _, _), do: fields

  defp add_timestamps(fields, start_date, end_date, "FINISHED") do
    [
      %{
        name: "Period",
        value: "#{format_date(start_date)} - #{format_date(end_date)}",
        inline: true
      }
      | fields
    ]
  end

  defp add_timestamps(fields, start_date, _end_date, _status) do
    [
      %{
        name: "Start",
        value: format_date(start_date),
        inline: true
      }
      | fields
    ]
  end

  defp format_date(nil), do: ""

  defp format_date(%{"year" => year, "month" => month, "day" => day}) do
    "#{year || "??"}.#{month || "??"}.#{day || "??"}"
  end
end
