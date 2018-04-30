defmodule Bot.Handler.Command.Uptime do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  def handle(message, _args) do
    {total, _} = :erlang.statistics(:wall_clock)

    total = div(total, 1000)

    seconds =
      rem(total, 60)
      |> to_string
      |> String.pad_leading(2, "0")

    total = div(total, 60)

    minutes =
      rem(total, 60)
      |> to_string
      |> String.pad_leading(2, "0")

    total = div(total, 60)

    hours =
      rem(total, 24)
      |> to_string
      |> String.pad_leading(2, "0")

    rest(:create_message, [message, [content: "Uptime: #{hours}:#{minutes}:#{seconds}"]])
  end
end
