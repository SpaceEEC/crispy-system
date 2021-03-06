defmodule Bot.Handler.Util do
  @moduledoc false

  import Bot.Handler.Rpc

  def chunk(title, text), do: chunk([], title, text) |> Enum.reverse()
  def chunk(fields, _title, nil), do: fields

  def chunk(fields, title, text) do
    [[first | _] | rest] = Regex.scan(~r/(.|[\r\n]){1,1024}/, text)

    fields = [%{name: title, value: first} | fields]

    Enum.reduce(
      rest,
      fields,
      &[%{name: "\u200b", value: List.first(&1)} | &2]
    )
  end

  def html_entity_to_utf8(str) do
    Regex.replace(
      ~r{&#(.+?);},
      str,
      fn _, m ->
        <<m |> String.to_integer()::utf8>>
      end
    )
  end

  @spec build_embed(
          track :: map(),
          author :: map(),
          type :: String.t(),
          loop :: boolean()
        ) :: Crux.Rest.embed()
  def build_embed(track, author, type, loop \\ false)
  def build_embed(%{info: info}, author, type, loop), do: build_embed(info, author, type, loop)

  def build_embed(track, author, type, loop) do
    time_string =
      track.length
      |> format_milliseconds()

    type_embed =
      type
      |> type_data()

    locale_key =
      if loop,
        do: :LOC_MUSIC_EMBED_LOOP,
        else: :LOC_MUSIC_EMBED

    me = cache(:User, :me!)

    %{
      author: %{
        name: "#{author.username}##{author.discriminator} (#{author.id})",
        icon_url: rest(Crux.Rest.CDN, :user_avatar, [author])
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      image: %{
        url: image_from_track(track)
      }
    }
    |> Map.merge(type_embed)
    |> Map.update!(:description, fn description ->
      {locale_key, [prefix: description, title: track.title, uri: track.uri, length: time_string]}
    end)
    |> put_in(
      [:footer, :icon_url],
      rest(Crux.Rest.CDN, :user_avatar, [me])
    )
  end

  defp type_data("save") do
    %{
      color: 0x7EB7E4,
      description: "💾",
      footer: %{
        text: :LOC_MUSIC_SAVE
      }
    }
  end

  defp type_data("play") do
    %{
      color: 0x00FF08,
      description: "**>>**",
      footer: %{
        text: :LOC_MUSIC_PLAY
      }
    }
  end

  defp type_data("add") do
    %{
      color: 0xFFFF00,
      description: "**++**",
      footer: %{
        text: :LOC_MUSIC_ADD
      }
    }
  end

  defp type_data("np") do
    %{
      color: 0x0800FF,
      description: "**>>**",
      footer: %{
        text: :LOC_MUSIC_NP
      }
    }
  end

  @spec image_from_track(any()) :: String.t() | nil
  def image_from_track(%{uri: "https://www.youtube.com/watch?v=" <> _id} = track),
    do: "https://img.youtube.com/vi/#{track.identifier}/mqdefault.jpg"

  def image_from_track(%{uri: "https://twitch.tv/" <> _channel} = track) do
    "https://static-cdn.jtvnw.net/previews-ttv/live_user_#{String.downcase(track.author)}-320x180.jpg"
  end

  # Soundcloud, why do you not offer a url scheme? :c
  def image_from_track(_other), do: nil

  @spec format_milliseconds(integer()) :: String.t()
  def format_milliseconds(time), do: time |> div(1000) |> format_seconds()

  @spec format_seconds(integer()) :: String.t()
  def format_seconds(time) when time > 86_400 do
    rest =
      time
      |> rem(86_400)
      |> format_seconds()

    "#{div(time, 86_400)} days #{rest}"
  end

  def format_seconds(time) when time > 3_600 do
    rest =
      time
      |> rem(3_600)
      |> format_seconds()

    "#{div(time, 3_600)}:#{rest}"
  end

  def format_seconds(time) do
    seconds =
      time
      |> rem(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    minutes =
      time
      |> div(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{minutes}:#{seconds}"
  end

  @spec ensure_connected(
          voice_states :: %{required(Crux.Rest.snowflake()) => Crux.Structs.VoiceState.t()},
          user_id :: Crux.Rest.snowflake()
        ) :: true | String.t()
  def ensure_connected(voice_states, user_id) do
    own_id = Application.fetch_env!(:bot_handler, :id)

    case voice_states do
      %{^own_id => %{channel_id: nil}} ->
        :LOC_MUSIC_SELF_DISCONNECTED

      %{^user_id => %{channel_id: nil}} ->
        :LOC_MUSIC_YOU_DISCONNECTED

      %{
        ^user_id => %{channel_id: user_channel_id},
        ^own_id => %{channel_id: own_channel_id}
      }
      when user_channel_id == own_channel_id ->
        true

      %{
        ^user_id => %{},
        ^own_id => %{}
      } ->
        :LOC_MUSIC_DIFFERENT_CHANNEL

      %{^own_id => %{}} ->
        :LOC_MUSIC_YOU_DISCONNECTED

      _ ->
        :LOC_MUSIC_SELF_DISCONNECTED
    end
  end

  @spec will_connect(
          voice_states :: %{required(Crux.Rest.snowflake()) => Crux.Structs.VoiceState.t()},
          user_id :: Crux.Rest.snowflake()
        ) :: Crux.Rest.snowflake() | String.t()
  def will_connect(voice_states, user_id) do
    own_id = Application.fetch_env!(:bot_handler, :id)

    case voice_states do
      %{^user_id => %{channel_id: nil}} ->
        :LOC_MUSIC_YOU_DISCONNECTED

      %{
        ^user_id => %{channel_id: user_channel_id},
        ^own_id => %{channel_id: own_channel_id}
      }
      when user_channel_id == own_channel_id ->
        0

      %{
        ^user_id => %{},
        ^own_id => %{channel_id: own_channel_id}
      }
      when not is_nil(own_channel_id) ->
        :LOC_MUSIC_DIFFERENT_CHANNEL

      %{^own_id => %{channel_id: own_channel_id}} when not is_nil(own_channel_id) ->
        :LOC_MUSIC_YOU_DISCONNECTED

      %{^user_id => %{channel_id: channel_id}} ->
        channel_id

      %{} ->
        :LOC_MUSIC_YOU_DISCONNECTED
    end
  end

  @spec decode_track(binary()) :: %{
          author: bitstring(),
          has_url: byte(),
          identifier: bitstring(),
          is_stream: byte(),
          length: non_neg_integer(),
          provider: bitstring(),
          title: bitstring(),
          url: nil | bitstring()
        }
  def decode_track(track) do
    <<
      _packet_length::32,
      _version::8,
      <<0>>,
      title_size::8,
      bin::binary
    >> = Base.decode64!(track)

    title_size = title_size * 8
    <<title::bitstring-size(title_size), <<0>>, author_size::8, bin::binary>> = bin

    author_size = author_size * 8
    <<author::bitstring-size(author_size), <<0>>, bin::binary>> = bin

    <<length::64, identifier_size::8, bin::binary>> = bin

    identifier_size = identifier_size * 8
    <<identifier::bitstring-size(identifier_size), bin::binary>> = bin

    <<is_stream::8, has_url::8, <<0>>, bin::binary>> = bin

    [url, bin] =
      if has_url == 1 do
        <<url_size::8, bin::binary>> = bin

        url_size = url_size * 8
        <<url::bitstring-size(url_size), <<0>>, bin::binary>> = bin

        [url, bin]
      else
        [nil, bin]
      end

    <<provider_size::8, bin::binary>> = bin
    provider_size = provider_size * 8
    <<provider::bitstring-size(provider_size), _bin::binary>> = bin

    %{
      title: title,
      author: author,
      length: length,
      identifier: identifier,
      is_stream: is_stream,
      has_url: has_url,
      url: url,
      provider: provider
    }
  end
end
