defmodule Bot.Handler.CommandInfo do
  @moduledoc false
  @enforce_keys [:args, :command, :locale]
  defstruct args: [], command: nil, locale: nil
  @type t :: %__MODULE__{args: [String.t()], command: String.t(), locale: String.t()}
end

defmodule Bot.Handler.Command do
  @moduledoc false

  # Info
  @callback aliases() :: [String.t()]
  @callback description() :: String.t() | atom()
  @callback examples() :: [String.t()]
  @callback guild_only() :: true
  @callback usages() :: [String.t()]

  # Work
  @callback inhibit(
              Crux.Structs.Message.t(),
              Bot.Handler.CommandInfo.t()
            ) :: {:respond, Crux.Rest.create_message_data()} | boolean()
  @callback fetch(
              Crux.Structs.Message.t(),
              Bot.Handler.CommandInfo.t()
            ) :: {:ok, term()} | {:respond, Crux.Rest.create_message_data()} | term()
  @callback process(
              Crux.Structs.Message.t(),
              term()
            ) :: {:respond, Crux.Rest.create_message_data()} | term()
  @callback respond(
              Crux.Structs.Message.t(),
              term()
            ) :: term()

  @optional_callbacks aliases: 0,
                      examples: 0,
                      guild_only: 0,
                      usages: 0,
                      inhibit: 2,
                      fetch: 2,
                      respond: 2

  alias Sentry.Context

  alias Bot.Handler.Command.Commands
  alias Bot.Handler.Config.Guild
  alias Bot.Handler.Locale

  import Bot.Handler.Rpc

  # for the guard
  require Bot.Handler.Locale

  @prefix "^"
  @owner_id Application.fetch_env!(:bot_handler, :owner_id)

  @spec get_prefix() :: String.t()
  def get_prefix(), do: @prefix

  @spec resolve(name_or_alias :: String.t()) :: nil | module()
  def resolve(name_or_alias) do
    Map.get(Commands.commands(), name_or_alias) || Map.get(Commands.aliases(), name_or_alias)
  end

  @spec handle(Crux.Structs.Message.t(), non_neg_integer()) :: :error | nil
  # No bots allowed here
  def handle(%{author: %{bot: true}}, _shard_id), do: nil

  def handle(message, shard_id) do
    Context.set_user_context(message.author |> Map.from_struct())

    message
    |> Map.take([:channel_id, :content, :guild_id])
    |> Map.put(:shard_id, shard_id)
    |> Context.set_extra_context()

    with {:ok, content} <- handle_prefix(message),
         [command | args] <- String.split(content, ~r/ +/, parts: :infinity),
         command <- String.downcase(command),
         mod when not is_nil(mod) <- resolve(command) do
      locale = Locale.fetch!(message)

      Context.add_breadcrumb(%{
        category: "Command",
        level: "info",
        message: command
      })

      Context.add_breadcrumb(%{
        category: "Locale",
        level: "info",
        message: locale
      })

      info = %Bot.Handler.CommandInfo{
        args: args,
        command: command,
        locale: locale
      }

      try do
        # For some reason it's not always loaded?
        Code.ensure_loaded(mod)
        run(mod, message, info)
      rescue
        e ->
          Sentry.capture_exception(e, stacktrace: __STACKTRACE__, tags: %{command: command})

          response = """
          ```elixir
          #{Exception.format_banner(:error, e) |> String.slice(0..1950)}
          ```
          """

          default_respond(message, response, info)
      end
    end
  end

  @spec handle_prefix(Crux.Structs.Message.t()) :: {:ok, String.t()} | :error
  defp handle_prefix(%{guild_id: nil, content: content}), do: {:ok, content}

  defp handle_prefix(%{guild_id: guild_id, content: content}) do
    prefix = Guild.get!(guild_id, "prefix", @prefix)

    case String.split_at(content, String.length(prefix)) do
      {^prefix, content} ->
        {:ok, content}

      _ ->
        regex = Regex.compile!("^<@!?#{Application.fetch_env!(:bot_handler, :id)}> *")

        case String.split(content, regex) do
          ["", content] ->
            {:ok, content}

          _ ->
            :error
        end
    end
  end

  def run(mod, message, info) do
    funs = :functions |> mod.__info__() |> Map.new()

    with true <- handle_guild_only(mod, message, info, funs),
         true <- inhibit(mod, message, info, funs),
         {:ok, info} <- fetch(mod, message, info, funs) do
      mod.process(message, info)
    end
    |> case do
      {:respond, response} ->
        respond(mod, message, {info, response}, funs)

      _ ->
        nil
    end
  end

  def handle_guild_only(_mod, %{guild_id: nil}, _args, %{guild_only: 0}) do
    {:respond, :LOC_GUILD_ONLY}
  end

  def handle_guild_only(_mod, _message, _args, _funs), do: true

  defp inhibit(_mod, %{author: %{id: @owner_id}}, _args, _funs), do: true
  defp inhibit(mod, message, args, %{inhibit: 2}), do: mod.inhibit(message, args)
  defp inhibit(_mod, _message, _args, _funs), do: true

  defp fetch(mod, message, args, %{fetch: 2}), do: mod.fetch(message, args)
  defp fetch(_mod, _message, args, _funs), do: {:ok, args}

  defp respond(mod, message, {_info, response}, %{respond: 2}), do: mod.respond(message, response)

  defp respond(_mod, message, {info, response}, _funs),
    do: default_respond(message, response, info)

  defp default_respond(message, response, info)
       when Locale.is_localizable(response)
       when is_bitstring(response) do
    default_respond(message, [content: response], info)
  end

  defp default_respond(message, response, info) do
    response = Locale.localize_response(response, info.locale)

    rest(:create_message!, [message.channel_id, response])
  end
end
