defmodule Bot.Rest.MixProject do
  use Mix.Project

  def project do
    {result, _exit_code} = System.cmd("git", ["rev-parse", "HEAD"])

    git_sha = String.slice(result, 0, 7)

    [
      app: :bot_rest,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crux_rest]
    ]
  end

  defp deps do
    [
      {:crux_rest, git: "http://github.com/spaceeec/crux_rest", override: true},
      {:crux_structs, git: "http://github.com/spaceeec/crux_structs", override: true},
      {:sentry, "~> 6.2.1"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.5.2", runtime: false}
    ]
  end
end
