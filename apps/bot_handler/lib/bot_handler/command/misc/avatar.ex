defmodule Bot.Handler.Command.Misc.Avatar do
  @moduledoc false

  @behaviour Bot.Handler.Command

  import Bot.Handler.Rpc

  alias Bot.Handler.Rest
  alias Crux.Structs

  def usages(), do: ["<User>"]
  def examples(), do: ["@space", "218348062828003328"]
  def description(), do: :LOC_DESC_AVATAR
  def fetch(message, %{args: []}), do: {:ok, message.author}

  def fetch(_message, %{args: [head | _tail]}) do
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
        with :error <- cache(:User, :fetch, [id]),
             {:error, _} <- rest(:get_user, [id]) do
          {:respond, :LOC_USER_NOT_FOUND}
        end

      _ ->
        {:respond, :LOC_USER_NOT_FOUND}
    end
  end

  def process(_message, %Crux.Structs.User{} = user) do
    avatar_url = rest(Crux.Rest.CDN, :user_avatar, [user, [size: 2048]])
    %{body: avatar} = Rest.get!(avatar_url)
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

  def handle(_message, %Structs.User{} = user) do
    avatar_url = rest(Crux.Rest.CDN, :user_avatar, [user, [size: 2048]])
    %{body: avatar} = Rest.get!(avatar_url)

    file_name = ("avatar" <> avatar_url) |> Path.extname() |> String.split("?") |> List.first()

    embed = %{
      author: %{
        name: "#{user.username}##{user.discriminator} (#{user.id})"
      },
      image: %{
        url: "attachment://#{file_name}"
      }
    }

    [files: [{avatar, file_name}], embed: embed]
  end
end
