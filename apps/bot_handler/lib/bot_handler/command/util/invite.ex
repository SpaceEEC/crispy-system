defmodule Bot.Handler.Command.Util.Invite do
  @behaviour Bot.Handler.Command

  @invite_url "https://discordapp.com/oauth2/authorize?client_id={{id}}&scope=bot&permissions={{permissions}}"

  alias Crux.Structs.Permissions
  import Bot.Handler.Util

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

    user = cache(User, :me!)

    url =
      @invite_url
      |> String.replace("{{id}}", to_string(user.id))
      |> String.replace("{{permissions}}", to_string(permissions))

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
