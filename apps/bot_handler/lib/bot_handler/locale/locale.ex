defmodule Bot.Handler.Locale do
  @moduledoc false
  @callback get_string(String.t()) :: String.t()

  alias Bot.Handler.Config.Guild

  defguard is_localizable(x) when (is_tuple(x) and tuple_size(x) == 2) or is_atom(x)

  @supported %{
    "de" => Bot.Handler.Locale.DE,
    "en" => Bot.Handler.Locale.EN
  }

  @spec get_supported() :: %{String.t() => module()}
  def get_supported(), do: @supported
  @spec supported?(String.t()) :: boolean()
  def supported?(locale), do: Map.has_key?(@supported, locale)

  @friendly_names %{
    "de" => "German (Deutsch)",
    "en" => "English (English)"
  }

  @spec get_friendly_names() :: %{String.t() => String.t()}
  def get_friendly_names(), do: @friendly_names
  @spec friendly_name!(String.t()) :: String.t() | no_return()
  def friendly_name!(name) do
    Map.get(@friendly_names, name) || raise("No such locale \"#{name}\"")
  end

  @default "en"

  @spec get_default() :: String.t()
  def get_default(), do: @default

  @spec fetch!(Crux.Structs.Message.t() | Crux.Rest.snowflake()) :: String.t() | no_return()
  def fetch!(%{guild_id: guild_id}), do: fetch!(guild_id)

  def fetch!(nil), do: @default

  def fetch!(guild_id), do: Guild.get!(guild_id, "lang", @default)

  @spec localize(String.t(), {String.t(), term()}) :: String.t() | no_return()
  def localize(locale, {key, kw}), do: localize(locale, key, kw)

  @spec localize(String.t(), String.t(), term()) :: String.t() | no_return()
  def localize(locale, key, kw \\ []) do
    mod = Map.get(@supported, locale) || raise "Unsupported locale: #{locale}"

    str = mod.get_string(key)

    Enum.reduce(kw, str, &String.replace(&2, "{{#{elem(&1, 0)}}}", &1 |> elem(1) |> to_string()))
  end

  @spec localize_response([{atom(), term()}] | map(), String.t()) :: map()
  def localize_response(response, locale)
      when not is_map(response) do
    response
    |> Map.new()
    |> localize_response(locale)
  end

  def localize_response(%{content: content} = response, locale)
      when is_localizable(content) do
    response
    |> Map.update!(:content, &localize(locale, &1))
    |> localize_response(locale)
  end

  def localize_response(%{embed: _embed} = response, locale) do
    response
    |> Map.update!(:embed, &localize_embed(&1, locale))

    # no recursion here
  end

  # done
  def localize_response(response, _locale), do: response

  def localize_embed(%{description: description} = embed, locale)
      when is_localizable(description) do
    embed
    |> Map.update!(:description, &localize(locale, &1))
    |> localize_embed(locale)
  end

  def localize_embed(%{title: title} = embed, locale)
      when is_localizable(title) do
    embed
    |> Map.update!(:title, &localize(locale, &1))
    |> localize_embed(locale)
  end

  def localize_embed(%{footer: %{text: text}} = embed, locale)
      when is_localizable(text) do
    embed
    |> update_in([:footer, :text], &localize(locale, &1))
    |> localize_embed(locale)
  end

  def localize_embed(%{author: %{name: name}} = embed, locale)
      when is_localizable(name) do
    embed
    |> update_in([:author, :name], &localize(locale, &1))
    |> localize_embed(locale)
  end

  def localize_embed(%{fields: _fields} = embed, locale) do
    embed
    |> Map.update!(:fields, &Enum.map(&1, fn field -> localize_field(field, locale) end))

    # no recursion here
  end

  # done
  def localize_embed(embed, _locale), do: embed

  defp localize_field(field, locale) do
    field
    |> Map.update!(:name, &localize_field_entry(&1, locale))
    |> Map.update!(:value, &localize_field_entry(&1, locale))
  end

  defp localize_field_entry(entry, locale)
       when is_localizable(entry) do
    localize(locale, entry)
  end

  defp localize_field_entry(entry, _locale), do: entry
end
