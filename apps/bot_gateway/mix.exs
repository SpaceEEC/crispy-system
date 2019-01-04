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
      mod: {Bot.Gateway, []},
      extra_applications: [:crux_gateway]
    ]
  end

  defp deps do
    [
      {:crux_gateway, git: "http://github.com/spaceeec/crux_gateway", override: true},
      {:sentry, "~> 7.0.3"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.0.12", runtime: false}
    ]
  end
end
