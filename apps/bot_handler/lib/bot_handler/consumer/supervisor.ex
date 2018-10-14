defmodule Bot.Handler.Consumer.Supervisor do
  @moduledoc false

  alias Bot.Handler.Rpc
  use ConsumerSupervisor

  def start_link([mod] = args) when is_atom(mod) do
    ConsumerSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(children) do
    if Node.ping(Rpc.cache()) == :pong do
      producers = Rpc._producers() |> Map.values()
      opts = [strategy: :one_for_one, subscribe_to: producers]

      ConsumerSupervisor.init(children, opts)
    else
      require Logger

      Logger.warn("[Bot][Handler][Consumer][Supervisor]: Cache is down, waiting 10 seconds.")
      Process.sleep(10_000)
      init(children)
    end
  end
end
