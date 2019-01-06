defmodule Bot.Cache.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot_cache,
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
      mod: {Bot.Cache.Application, []},
      included_applications: [:crux_base, :crux_rest, :crux_gateway]
    ]
  end

  defp deps do
    [
      {:crux_cache, git: "http://github.com/spaceeec/crux_cache", override: true},
      {:crux_structs, git: "http://github.com/spaceeec/crux_structs", override: true},
      # A bit ugly, but it's a dep of base after all
      {:crux_base, git: "https://github.com/spaceeec/crux_base"},
      {:crux_gateway,
       git: "http://github.com/spaceeec/crux_gateway", override: true, runtime: false},
      {:crux_rest, git: "http://github.com/spaceeec/crux_rest", override: true, runtime: false},
      {:sentry, git: "https://github.com/spaceeec/sentry-elixir", branch: "fix/umbrella_path"},
      {:gen_stage, "~> 0.13.1"},
      {:distillery, "~> 2.0.12", runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end
end
