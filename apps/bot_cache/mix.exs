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
      {:crux_cache, "~> 0.1.0"},
      {:crux_structs, git: "http://github.com/spaceeec/crux_structs", override: true},
      {:gen_stage, "~> 0.13.1"}
    ]
  end
end
