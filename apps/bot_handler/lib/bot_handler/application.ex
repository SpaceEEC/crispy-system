defmodule Bot.Handler.Application do
  @moduledoc false

  use Application
  import Bot.Handler.Util, only: [cache: 3]

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    children = [
      Bot.Handler.Music.Supervisor,
      {Bot.Handler.Consumer.Supervisor, [Bot.Handler.Consumer]}
    ]

    children =
      case cache(User, :me, []) do
        {:ok, _user} ->
          [Bot.Handler.Lavalink.Connection | children]

        :error ->
          children
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: Bot.Handler.Supervisor)
  end
end
