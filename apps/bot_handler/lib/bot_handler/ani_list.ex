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

  alias Bot.Handler.{Awaiter, Locale, Rest, Util}
  import Bot.Handler.Rpc

  def fetch("", _type), do: {:respond, :LOC_ANI_LIST_NO_QUERY}

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
    {:respond, :LOC_ANI_LIST_NOTHING_FOUND}
  end

  defp handle_response(%{body: %{"data" => %{"result" => %{"results" => results}}}}) do
    {:ok, results}
  end

  # Shouldn't ever get to this clause, but better safe than sorry.
  def pick(_message, [], _type), do: {:respond, :LOC_ANI_LIST_NOTHING_FOUND}
  def pick(_message, [element], _type), do: element

  def pick(%{author: %{id: author_id}, channel_id: channel_id} = message, elements, type)
      when type in ["ANIME", "CHARACTER", "MANGA"] do
    locale = Locale.fetch!(message)

    prompt =
      rest(:create_message!, [
        channel_id,
        [
          embed:
            %{
              title: {:LOC_ANI_LIST_PROMPT_TITLE, [type: type |> String.downcase()]},
              description: format_elements(elements),
              fields: [
                %{
                  name: :LOC_ANI_LIST_PROMPT_FIELD_NAME,
                  value: {:LOC_ANI_LIST_PROMPT_FIELD_VALUE, [type: type |> String.downcase()]}
                }
              ]
            }
            |> Locale.localize_embed(locale)
        ]
      ])

    response =
      Awaiter.await(
        :MESSAGE_CREATE,
        fn
          {_, %{author: %{id: ^author_id}}, _} -> true
          _ -> false
        end,
        30_000
      )
      |> case do
        {_, message, _} -> message
        other -> other
      end

    rest(:delete_message, [prompt])

    if response == :timeout do
      {:respond, :LOC_ANI_LIST_CANCEL}
    else
      rest(:delete_message, [response])

      response.content
      |> String.downcase()
      |> handle_response(elements)
    end
  end

  defp handle_response("cancel", _elements), do: {:respond, :LOC_ANI_LIST_CANCEL}

  defp handle_response(content, elements) do
    with {number, _} when number > 0 <- Integer.parse(content),
         char when not is_nil(char) <- Enum.at(elements, number - 1) do
      char
    else
      {_number, _rest} ->
        {:respond, :LOC_ANI_LIST_NO_SUCH_ENTRY}

      :error ->
        {:respond, :LOC_ANI_LIST_NOT_A_NUMBER}

      nil ->
        {:respond, :LOC_ANI_LIST_NO_SUCH_ENTRY}
    end
  end

  defp format_elements(elements) do
    length = elements |> Enum.count() |> to_string() |> String.length()

    elements
    |> Enum.with_index()
    |> Enum.map_join("\n", &format_entry(&1, length))
    |> String.slice(0..2023)
  end

  # Character
  defp format_entry({%{"name" => %{"first" => first_name, "last" => last_name}}, i}, length) do
    i = i |> Kernel.+(1) |> to_string() |> String.pad_trailing(length, " ")
    "`#{i}` - #{first_name || ""} #{last_name || ""}"
  end

  # Anime / Manga
  defp format_entry(
         {%{"title" => %{"english" => title_english, "romaji" => title_romaji}}, i},
         length
       ) do
    i = i |> Kernel.+(1) |> to_string() |> String.pad_trailing(length, " ")
    title = if_empty(title_english, title_romaji)
    "`#{i}` - #{title}"
  end

  defp if_empty(nil, other), do: other
  defp if_empty("", other), do: other

  defp if_empty(str, other) do
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
      color: 0x02A8FE,
      thumbnail: %{
        url: large_image
      },
      url: site_url,
      title: "\u200b#{first_name} #{last_name}",
      description: native_name |> Kernel.||("") |> Util.html_entity_to_utf8()
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
            name: :LOC_ANI_LIST_ALIASES,
            value: alternative_names |> Enum.map(&Util.html_entity_to_utf8/1) |> Enum.join(", "),
            inline: true
          }

          Map.update(embed, :fields, [field], &[field | &1])
      end

    rest = Util.chunk(:LOC_ANI_LIST_DESCRIPTION, description)

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
    [title, embed_description] = map_titles(titles)

    genres =
      genres
      |> Enum.chunk_every(3)
      |> Enum.map_join("\n", &Enum.join(&1, ", "))

    fields =
      [
        %{
          name: :LOC_ANI_LIST_RATING_TYPE,
          value: "#{average_score || mean_score || "??"} | #{type |> String.capitalize()}",
          inline: true
        },
        %{
          name: :LOC_ANI_LIST_GENRES,
          value: if_empty(genres, "??"),
          inline: true
        }
      ]
      |> add_counts(type, episodes, chapters, volumes)
      |> add_timestamps(start_date, end_date, status)
      |> Util.chunk(:LOC_ANI_LIST_DESCRIPTION, if_empty(description, "??"))
      |> add_status(type, status)
      |> add_source(type, source)
      |> Enum.reverse()

    %{
      thumbnail: %{url: large_image},
      url: site_url,
      title: title,
      description: embed_description,
      fields: fields,
      color: 0x02A8FE
    }
  end

  defp map_titles(titles) do
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
        name: :LOC_ANI_LIST_ORIGIN,
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
        "ANIME" -> :LOC_ANI_LIST_AIRING_STATUS
        "MANGA" -> :LOC_ANI_LIST_PUBLISHING_STATUS
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
        name: :LOC_ANI_LIST_EPISODES,
        value: episodes || "??",
        inline: true
      }
      | fields
    ]
  end

  defp add_counts(fields, "MANGA", _episodes, chapters, volumes) do
    [
      %{
        name: :LOC_ANI_LIST_CHAPTERS_VOLUMES,
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
        name: :LOC_ANI_LIST_PERIOD,
        value: "#{format_date(start_date)} - #{format_date(end_date)}",
        inline: true
      }
      | fields
    ]
  end

  defp add_timestamps(fields, start_date, _end_date, _status) do
    [
      %{
        name: :LOC_ANI_LIST_START,
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
