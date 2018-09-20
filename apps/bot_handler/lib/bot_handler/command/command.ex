defmodule Bot.Handler.Command do
  # Info
  @callback aliases() :: [String.t()]
  @callback usages() :: [String.t()]
  @callback examples() :: [String.t()]
  @callback description() :: String.t()

  # Work
  @callback inhibit(Crux.Structs.Message.t(), [String.t()]) ::
              {:respond, Crux.Rest.create_message_data()} | boolean()
  @callback fetch(Crux.Structs.Message.t(), [String.t()]) ::
              {:ok, term()} | {:respond, Crux.Rest.create_message_data()} | term()
  @callback process(Crux.Structs.Message.t(), term()) ::
              {:respond, Crux.Rest.create_message_data()} | term()
  @callback respond(Crux.Structs.Message.t(), term()) :: term()

  @optional_callbacks usages: 0, examples: 0, aliases: 0, inhibit: 2, fetch: 2, respond: 2

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
  def handle(%{guild_id: guild_id} = message) when not is_nil(guild_id) do
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

  def handle(_message), do: nil

  defp handle_prefix(%{guild_id: guild_id, content: content}) do
    with {:ok, prefix} <- Guild.get(guild_id, "prefix", @prefix),
         {^prefix, content} <- String.split_at(content, String.length(prefix)) do
      {:ok, content}
    else
      _ ->
        :error
        # with {:ok, %{id: user_id}} <- cache(:User, :me, []),
        #      ["", content] <- String.split(content, Regex.compile!("^<@!?#{user_id}> *")) do
        #   {:ok, content}
        # else
        #   _ ->
        #     :error
        # end
    end
  end

  def run(mod, message, args) do
    with true <- inhibit(mod, message, args),
         {:ok, args} <- fetch(mod, message, args) do
      mod.process(message, args)
    end
    |> case do
      {:respond, response} ->
        respond(mod, message, response)

      _ ->
        nil
    end
  end

  defp inhibit(mod, message, args) do
    if function_exported?(mod, :inhibit, 2) do
      mod.inhibit(message, args)
    else
      true
    end
  end

  defp fetch(mod, message, args) do
    if function_exported?(mod, :fetch, 2) do
      mod.fetch(message, args)
    else
      {:ok, args}
    end
  end

  defp respond(mod, message, response) do
    if function_exported?(mod, :respond, 2) do
      mod.respond(message, response)
    else
      default_respond(message, response)
    end
  end

  defp default_respond(message, response) when is_bitstring(response) do
    default_respond(message, content: response)
  end

  defp default_respond(message, response) do
    rest(:create_message!, [message.channel_id, response])
  end
end
