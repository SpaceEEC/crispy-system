defmodule Bot.Handler.Command.Util.Invite do
  @behaviour Bot.Handler.Command

  def description(), do: "Invite the bot to your server."

  @invite_url "https://discordapp.com/oauth2/authorize?client_id={{id}}&scope=bot&permissions={{permissions}}"

  alias Crux.Structs.Permissions

  def process(_message, _args) do
    permissions =
      Permissions.resolve([
        :view_channel,
        :send_messages,
        # :manage_messages,
        :embed_links,
        :attach_files,
        # :external_emojis,
        # :add_reactions,
        :connect,
        :speak
      ])
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
        name: "Invite",
        url: url
      },
      description: """
      To invite me to your server click [this](#{url}) link.
      **Note**: You need the **Manage Server** permission to add me there.
      \u200b
      """
    }

    {:respond, [embed: embed]}
  end
end
