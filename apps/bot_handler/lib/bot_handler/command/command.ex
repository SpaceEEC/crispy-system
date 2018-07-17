defmodule Bot.Handler.Command do
  @callback aliases() :: [String.t()]
  @callback inhibit(Crux.Structs.Message.t(), [String.t()]) ::
              {:respond, Crux.Rest.create_message_data()} | boolean()
  @callback fetch(Crux.Structs.Message.t(), [String.t()]) ::
              {:ok, term()} | {:respond, Crux.Rest.create_message_data()} | term()
  @callback process(Crux.Structs.Message.t(), term()) ::
              {:respond, Crux.Rest.create_message_data()} | term()
  @callback respond(Crux.Structs.Message.t(), term()) :: term()

  @optional_callbacks aliases: 0, inhibit: 2, fetch: 2, respond: 2

  @prefix "ß"

  alias Bot.Handler.Command.Commands

  import Bot.Handler.Util

  def handle(%{content: @prefix <> content} = message) do
    [command | args] = String.split(content, ~r/ +/, parts: :infinity)
    command = String.downcase(command)

    case Commands.commands() |> Map.get(command) || Commands.aliases() |> Map.get(command) do
      nil ->
        nil

      mod ->
        run(mod, message, args)
    end
  end

  def handle(_message), do: nil

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
    rest(:create_message, [message.channel_id, response])
  end
end
