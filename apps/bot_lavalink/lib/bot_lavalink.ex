defmodule Bot.Lavalink do
  @moduledoc false

  use Application
  import Bot.Handler.Rpc

  def start(_type, _args) do
    :ok = :error_logger.add_report_handler(Sentry.Logger)

    case Node.ping(gateway()) do
      :pong ->
        alias Bot.Lavalink.{Connection, Player}
        children = [{Connection, []}, {Player.Supervisor, []}]

        Supervisor.start_link(children, strategy: :one_for_one, name: Bot.Lavalink.Supervisor)

      :pang ->
        {:error, :gateway_not_started}
    end
  end
end
