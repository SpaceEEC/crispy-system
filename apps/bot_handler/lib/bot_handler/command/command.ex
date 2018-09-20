defmodule Bot.Handler.Command do
  # Info
  @callback aliases() :: [String.t()]
  @callback description() :: String.t()
  @callback examples() :: [String.t()]
  @callback guild_only() :: true
  @callback usages() :: [String.t()]

  # Work
  @callback inhibit(Crux.Structs.Message.t(), [String.t()]) ::
              {:respond, Crux.Rest.create_message_data()} | boolean()
  @callback fetch(Crux.Structs.Message.t(), [String.t()]) ::
              {:ok, term()} | {:respond, Crux.Rest.create_message_data()} | term()
  @callback process(Crux.Structs.Message.t(), term()) ::
              {:respond, Crux.Rest.create_message_data()} | term()
  @callback respond(Crux.Structs.Message.t(), term()) :: term()

  @optional_callbacks aliases: 0,
                      examples: 0,
                      guild_only: 0,
                      usages: 0,
                      inhibit: 2,
                      fetch: 2,
                      respond: 2

  @prefix "ß"

  @spec get_prefix() :: String.t()
  def get_prefix(), do: @prefix

  alias Bot.Handler.Command.Commands
  alias Bot.Handler.Config.Guild

  import Bot.Handler.Util

  @spec resolve(name_or_alias :: String.t()) :: nil | module()
  def resolve(name_or_alias) do
    case Commands.commands() do
      %{^name_or_alias => command} ->
        command

      _ ->
        case Commands.aliases() do
          %{^name_or_alias => command} ->
            command

          _ ->
            nil
        end
    end
  end

  def handle(%{author: %{bot: true}}), do: nil

  def handle(message) do
    with {:ok, content} <- handle_prefix(message) do
      [command | args] = String.split(content, ~r/ +/, parts: :infinity)
      command = String.downcase(command)

      case resolve(command) do
        nil ->
          nil

        mod ->
          try do
            # For some reason it's not always loaded?
            Code.ensure_loaded(mod)
            run(mod, message, args)
          rescue
            e ->
              default_respond(
                message,
                "```elixir\n#{Exception.format_banner(:error, e)}```"
              )

              reraise(e, __STACKTRACE__)
          end
      end
    end
  end

  defp handle_prefix(%{guild_id: nil, content: content}) do
    #{:ok, content}
    :error
  end

  defp handle_prefix(%{guild_id: guild_id, content: content}) do
    with {:ok, prefix} <- Guild.get(guild_id, "prefix", @prefix),
         {^prefix, content} <- String.split_at(content, String.length(prefix)) do
      {:ok, content}
    else
      _ ->
        # with {:ok, %{id: user_id}} <- cache(:User, :me, []),
        #     ["", content] <- String.split(content, Regex.compile!("^<@!?#{user_id}> *")) do
        #  {:ok, content}
        # else
        #  _ ->
        :error
        # end
    end
  end

  def run(mod, message, args) do
    funs = mod.__info__(:functions) |> Map.new()

    with true <- handle_guild_only(mod, message, args, funs),
         true <- inhibit(mod, message, args, funs),
         {:ok, args} <- fetch(mod, message, args, funs) do
      mod.process(message, args)
    end
    |> case do
      {:respond, response} ->
        respond(mod, message, response, funs)

      _ ->
        nil
    end
  end

  def handle_guild_only(_mod, %{guild_id: nil}, _args, %{guild_only: 0}) do
    {:respond, "That command may not be used in dms."}
  end

  def handle_guild_only(_mod, _message, _args, _funs), do: true

  defp inhibit(mod, message, args, %{inhibit: 2}), do: mod.inhibit(message, args)
  defp inhibit(_mod, _message, _args, _funs), do: true

  defp fetch(mod, message, args, %{fetch: 2}), do: mod.fetch(message, args)
  defp fetch(_mod, _message, args, _funs), do: {:ok, args}

  defp respond(mod, message, response, %{respond: 2}), do: mod.respond(message, response)
  defp respond(_mod, message, response, _funs), do: default_respond(message, response)

  defp default_respond(message, response) when is_bitstring(response) do
    default_respond(message, content: response)
  end

  defp default_respond(message, response) do
    rest(:create_message!, [message.channel_id, response])
  end
end
