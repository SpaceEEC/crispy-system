defmodule Bot.Rest.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot_rest,
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
      extra_applications: [:crux_rest],
      mod: {Bot.Rest, []}
    ]
  end

  defp deps do
    [
      {:crux_rest, git: "http://github.com/spaceeec/crux_rest", override: true},
      {:crux_structs, git: "http://github.com/spaceeec/crux_structs", override: true},
      {:sentry, git: "https://github.com/spaceeec/sentry-elixir", branch: "fix/umbrella_path"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.0.12", runtime: false}
    ]
  end
end
