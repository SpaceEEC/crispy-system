defmodule Bot.Handler.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot_handler,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bot.Handler.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crux_structs, git: "http://github.com/spaceeec/crux_structs", override: true},
      {:poison, "~> 3.1.0"},
      {:gen_stage, "~> 0.13.1"},
      {:httpoison, "~> 1.1.1"},
      {:websockex, "~> 0.4.1"},
      {:sentry, "~> 6.2.1"},
      {:distillery, "~> 1.5.2", runtime: false}
    ]
  end
end
