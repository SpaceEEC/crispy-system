defmodule Bot.Handler.Command.Misc.Avatar do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  alias Crux.Structs

  def fetch(message, []), do: {:ok, message.author}

  def fetch(_message, [head | _tail]) do
    head
    |> case do
      # Mention with nickname
      "<@!" <> rest ->
        rest
        |> String.slice(0..-2)

      # Mention without nickname
      "<@" <> rest ->
        rest
        |> String.slice(0..-2)

      # Maybe id
      _ ->
        head
    end
    |> Integer.parse()
    |> case do
      # 16 - 19 chars long
      {id, ""} when id >= 1.0e15 and id <= 1.0e18 ->
        with :error <- cache(User, :fetch, [id]),
             {:error, _} <- rest(:get_user, [id]) do
          {:respond, "Could not find that user"}
        end

      _ ->
        {:respond, "Could not find that user"}
    end
  end

  def process(_message, %Crux.Structs.User{} = user) do
    avatar_url = rest(Crux.Rest.CDN, :user_avatar, [user, [size: 2048]])
    %{body: avatar} = Bot.Handler.Rest.get!(avatar_url)
    extension = avatar_url |> Path.extname() |> String.split("?") |> List.first()

    embed = %{
      author: %{
        name: "#{user.username}##{user.discriminator} (#{user.id})"
      },
      image: %{
        url: "attachment://avatar#{extension}"
      }
    }

    files = [{avatar, "avatar" <> extension}]

    {:respond, [files: files, embed: embed]}
  end

  def handle(message, %Structs.User{} = user) do
    avatar_url = rest(Crux.Rest.CDN, :user_avatar, [user, [size: 2048]])
    %{body: avatar} = Bot.Handler.Rest.get!(avatar_url)

    file_name = ("avatar" <> avatar_url) |> Path.extname() |> String.split("?") |> List.first()

    embed = %{
      author: %{
        name: "#{user.username}##{user.discriminator} (#{user.id})"
      },
      image: %{
        url: "attachment://#{file_name}"
      }
    }

    files = [{avatar, file_name}]

    rest(:create_message, [message.channel_id, [files: files, embed: embed]])
  end
end
