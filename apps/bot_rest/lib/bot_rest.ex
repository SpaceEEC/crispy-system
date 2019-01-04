defmodule Bot.Rest do
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    {:ok, spawn(fn -> :timer.sleep(:infinity) end)}
  end
end
