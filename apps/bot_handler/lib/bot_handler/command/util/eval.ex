defmodule Bot.Handler.Command.Util.Eval do
  @behaviour Bot.Handler.Command

  def inhibit(message, _args) do
    message.author.id == 218_348_062_828_003_328
  end

  def process(message, args) do
    {res, _binding} =
      try do
        args
        |> Enum.join(" ")
        |> Code.eval_string(message: message)
      rescue
        e -> {Exception.format(:error, e), nil}
      end

    res =
      if(is_bitstring(res), do: res, else: inspect(res))
      |> String.slice(0, 1950)

    {:respond, "```elixir\n#{res}\n```"}
  end
end
