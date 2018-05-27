defmodule Bot.Handler.Command.Ping do
  @behaviour Bot.Handler.Command

  import Bot.Handler.Util

  def handle(message, _args) do
    rest(:create_message, [message, [content: "Peng! 💥"]])
  end
end
