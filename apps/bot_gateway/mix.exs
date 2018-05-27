defmodule Bot.Gateway.MixProject do
  use Mix.Project

  def project do
    {result, _exit_code} = System.cmd("git", ["rev-parse", "HEAD"])

    git_sha = String.slice(result, 0, 7)

    [
      app: :bot_gateway,
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
      extra_applications: [:crux_gateway]
    ]
  end

  defp deps do
    [
      {:crux_gateway, git: "http://github.com/spaceeec/crux_gateway", override: true},
      {:sentry, "~> 6.2.1"},
      {:distillery, "~> 1.5.2", runtime: false}
    ]
  end
end
