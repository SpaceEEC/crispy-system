defmodule Bot.Handler.Command.Util.Ping do
  @behaviour Bot.Handler.Command

  def process(_message, _args) do
    {:respond, "Peng! 💥"}
  end
end
