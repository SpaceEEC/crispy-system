defmodule Bot.Handler.Command.Util.Ping do
  @moduledoc false

  @behaviour Bot.Handler.Command

  def description(), do: "Ping? Pong? Peng!"

  def process(_message, _args) do
    {:respond, "Peng! 💥"}
  end
end
