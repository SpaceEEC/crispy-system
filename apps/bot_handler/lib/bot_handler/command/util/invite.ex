defmodule Bot.Handler.Command.Util.Invite do
  @moduledoc false

  @behaviour Bot.Handler.Command

  def description(), do: :LOC_DESC_INVITE

  @invite_url "https://discordapp.com/oauth2/authorize?client_id={{id}}&scope=bot&permissions={{permissions}}"

  alias Crux.Structs.Permissions

  def process(_message, _args) do
    permissions =
      [
        :view_channel,
        :send_messages,
        # :manage_messages,
        :embed_links,
        :attach_files,
        # :external_emojis,
        # :add_reactions,
        :connect,
        :speak
      ]
      |> Permissions.resolve()
      |> to_string()

    id =
      Application.fetch_env!(:bot_handler, :id)
      |> to_string()

    url =
      @invite_url
      |> String.replace("{{id}}", id)
      |> String.replace("{{permissions}}", permissions)

    embed = %{
      author: %{
        name: :LOC_INVITE,
        url: url
      },
      description: {:LOC_INVITE_DESCRIPTION, [url: url]}
    }

    {:respond, [embed: embed]}
  end
end
