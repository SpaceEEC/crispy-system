defmodule Bot.Handler.Awaiter.Supervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def start_child(args) do
    Supervisor.start_child(
      __MODULE__,
      Supervisor.child_spec(
        {Bot.Handler.Awaiter, args},
        id: args,
        restart: :temporary
      )
    )
  end
end
