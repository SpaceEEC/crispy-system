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
      mod: {Bot.Cache.Application, []}
    ]
  end

  defp deps do
    [
      {:crux_cache, git: "http://github.com/spaceeec/crux_cache", override: true},
      {:crux_structs, git: "http://github.com/spaceeec/crux_structs", override: true},
      {:sentry, "~> 6.2.1"},
      {:gen_stage, "~> 0.13.1"},
      {:distillery, "~> 1.5.2", runtime: false}
    ]
  end
end
