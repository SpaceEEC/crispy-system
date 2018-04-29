defmodule Bot.Handler.Command.Eval do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  def inhibit(message, _args) do
    message.author.id == 218_348_062_828_003_328
  end

  def handle(message, args) do
    {res, _binding} =
      try do
        Code.eval_string(Enum.join(args, " "), message: message, Crux: Crux, Bot: Bot)
      rescue
        e -> {Exception.format(:error, e), nil}
      end

    res =
      if(is_bitstring(res), do: res, else: inspect(res))
      |> String.slice(0, 1950)

    rest(:create_message, [message, [content: "```elixir\n#{res}\n```"]])
  end
end
