defmodule Bot.Handler do
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    if Bot.Handler.Util._cache_alive?() do
      children = [
        Bot.Handler.Lavalink.Connection,
        Bot.Handler.Music.Supervisor,
        {Bot.Handler.Consumer.Supervisor, [Bot.Handler.Consumer]}
      ]

      Supervisor.start_link(children, strategy: :one_for_one, name: Bot.Handler.Supervisor)
    else
      {:error, :cache_not_started}
    end
  end
end
