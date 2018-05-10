defmodule Bot.Gateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot_gateway,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:crux_gateway]
    ]
  end

  defp deps do
    [
      {:sentry, "~> 6.2.1"},
      {:crux_gateway, "~> 0.1.0"}
    ]
  end
end
