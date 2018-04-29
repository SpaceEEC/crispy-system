defmodule Bot.Handler.Consumer.Supervisor do
  use ConsumerSupervisor

  def start_link([mod] = args) when is_atom(mod) do
    ConsumerSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(children) do
    producers = Bot.Handler.Util._producers() |> Map.values()
    opts = [strategy: :one_for_one, subscribe_to: producers]

    ConsumerSupervisor.init(children, opts)
  end
end
