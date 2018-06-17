defmodule Bot.Cache.MixProject do
  use Mix.Project

  def project do
    {result, _exit_code} = System.cmd("git", ["rev-parse", "HEAD"])

    git_sha = String.slice(result, 0, 7)

    [
      app: :bot_cache,
      version: "0.1.0-#{git_sha}",
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
      # A bit ugly, but it's a dep of base after all
      {:crux_base, git: "https://github.com/spaceeec/crux_base", runtime: false},
      {:crux_gateway,
       git: "http://github.com/spaceeec/crux_gateway", override: true, runtime: false},
      {:crux_rest, git: "http://github.com/spaceeec/crux_rest", override: true, runtime: false},
      {:sentry, "~> 6.2.1"},
      {:gen_stage, "~> 0.13.1"},
      {:distillery, "~> 1.5.2", runtime: false}
    ]
  end
end
