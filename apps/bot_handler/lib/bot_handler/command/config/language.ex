defmodule Bot.Handler.Command.Config.Language do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Bot.Handler.Config.Guild
  alias Bot.Handler.Locale
  alias Crux.Structs.Permissions

  def aliases(), do: ["lang"]
  def description(), do: :LOC_DESC_LANGUAGE
  def examples(), do: ["", "de", "en"]
  def guild_only(), do: true
  def usages(), do: ["", "<Language>"]

  def inhibit(_message, %{args: []}), do: true

  def inhibit(%{member: member, guild_id: guild_id}, _) do
    guild = cache(:Guild, :fetch!, [guild_id])

    member
    |> Permissions.from(guild)
    |> Permissions.has(:manage_guild) || {:respond, :LOC_LANG_PERMS}
  end

  def fetch(_message, %{args: []}), do: {:ok, []}

  def fetch(_message, %{args: [new_lang | _]}) do
    new_lang = String.downcase(new_lang)

    if Locale.supported?(new_lang) do
      {:ok, new_lang}
    else
      supported =
        Locale.get_friendly_names()
        |> Enum.map_join("\n", &"`#{elem(&1, 0)}` -> `#{elem(&1, 1)}`")

      {:respond, {:LOC_LANG_INVALID, [lang: new_lang, supported: supported]}}
    end
  end

  def process(%{guild_id: guild_id}, []) do
    lang =
      guild_id
      |> Locale.fetch!()
      |> Locale.friendly_name!()

    {:respond, {:LOC_LANG_CURRENT, [lang: lang]}}
  end

  def process(%{guild_id: guild_id}, new_lang) do
    Guild.put!(guild_id, "lang", new_lang)

    {:respond, {:LOC_LANG_SET, [new: Locale.friendly_name!(new_lang)]}}
  end
end
