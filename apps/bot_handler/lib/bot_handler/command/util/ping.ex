defmodule Bot.Handler.Command.Util.Ping do
  @moduledoc false

  @behaviour Bot.Handler.Command

  @spec description() :: String.t() | atom()
  def description(), do: "Ping? Pong? Pang!"

  def process(_message, _args) do
    {:respond, "Pang! 💥"}
  end
end
