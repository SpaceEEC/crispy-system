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

    days = div(total, 24)

    uptime =
      if days == 0 do
        "Uptime:"
      else
        "Uptime: #{days} days"
      end

    uptime = "#{uptime} #{hours}:#{minutes}:#{seconds}"

    rest(:create_message, [message, [content: uptime]])
  end
end
