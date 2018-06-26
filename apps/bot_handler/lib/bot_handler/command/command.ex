defmodule Bot.Handler.Command do
  @callback aliases() :: [String.t()]
  @callback inhibit(Crux.Structs.Message, [String.t()]) :: boolean()
  @callback handle(Crux.Structs.Message, [String.t()]) :: term()

  @optional_callbacks aliases: 0, inhibit: 2

  @prefix "ß"

  alias Bot.Handler.Command.Commands

  def handle(%{content: @prefix <> content} = message) do
    [command | args] = String.split(content, ~r/ +/, parts: :infinity)
    command = String.downcase(command)

    case fetch_command(command) do
      nil ->
        nil

      mod ->
        if inhibit_command(mod, message, args) do
          mod.handle(message, args)
        end
    end
  end

  def handle(_message), do: nil

  defp fetch_command(command) do
    Commands.commands()
    |> Map.get(command) ||
      Commands.aliases()
      |> Map.get(command)
  end

  defp inhibit_command(mod, message, args) do
    if function_exported?(mod, :inhibit, 2) do
      mod.inhibit(message, args)
    else
      true
    end
  end
end
