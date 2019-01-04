defmodule Bot.Lavalink.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot_lavalink,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:websockex, :httpoison, :sentry],
      extra_applications: [:logger],
      mod: {Bot.Lavalink, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.2"},
      {:sentry, "~> 7.0.3"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:bot_handler, in_umbrella: true}
    ]
  end
end
