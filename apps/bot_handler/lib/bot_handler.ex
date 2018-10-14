defmodule Bot.Handler do
  @moduledoc false

  use Application
  alias Bot.Handler.{Awaiter, Consumer, Rpc}

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    if Node.ping(Rpc.cache()) == :pong do
      children = [
        Awaiter.Supervisor,
        {Consumer.Supervisor, [Consumer]}
      ]

      Supervisor.start_link(children, strategy: :one_for_one, name: Bot.Handler.Supervisor)
    else
      {:error, :cache_not_started}
    end
  end
end
