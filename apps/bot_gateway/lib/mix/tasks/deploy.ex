defmodule Mix.Tasks.Deploy do
  @moduledoc false

  defmodule Local do
    @shortdoc "Deploy release to local machine"

    @moduledoc """
    This task deploys a Distillery release to the local machine.

    It extracts the release tar to a timestamped directory like
    `/opt/:app/releases/20170619T175601Z`, then makes a symlink
    from `/opt/:app/current` to it.

    The location of the releases is controlled by variables in the `project`
    section of `mix.exs`, e.g.

    ```elixir
    def project do
      [
        app: :foo_bar,
        version: "0.1.0",
        deploy_dir: "/opt/project/foo-bar",
        deps: deps()
      ]
    end
    ```

    Standard variables:

    * `app`: Name of the app
    * `version`: Version string

    Variables specific to this task:
    * `deploy_base`: Base of the directory tree, default `/opt`
    * `deploy_dir`: Base of deploy, default `/:deploy_base/:app`
    """

    use Mix.Task

    def run(args) do
      # IO.puts (inspect args)
      config = parse_args(args)

      # You can run other tasks before deploying:
      # Mix.Task.run("release")
      # Mix.Task.run("ecto.create", ["--quiet"])

      deploy_release(config)

      nil
    end

    def deploy_release(config) do
      Mix.shell().info("Deploying release to #{config.deploy_dir}")

      if config.new do
        File.mkdir_p!(config.deploy_dir)
        Mix.shell().info("Extracting tarball #{config.tarball}")
        :ok = :erl_tar.extract(config.tarball, [{:cwd, config.deploy_dir}, :compressed])
      else
        Mix.shell().info("Copying tarball #{config.tarball}")
        target_dir = "#{config.deploy_dir}/releases/#{config.version}"
        File.mkdir_p!(target_dir)
        File.copy!(config.tarball, "#{target_dir}/#{config.app_name}.tar.gz")

        if config.upgrade do
          Mix.shell().info("Upgrading...")
          executeable_path = "#{config.deploy_dir}/bin/#{config.app_name}"
          System.cmd(executeable_path, ["upgrade", config.version])
        end
      end

      nil
    end

    # def create_timestamp do
    # {{year, month, day}, {hour, minute, second}} = :calendar.now_to_universal_time(:os.timestamp())
    # timestamp = :io_lib.format("~4..0B~2..0B~2..0B~2..0B~2..0B~2..0B", [year, month, day, hour, minute, second])
    # timestamp |> List.flatten |> to_string
    # end

    # There is a problem the startup scripts if the path includes ":" chars
    # def create_timestamp do
    #   date_time = DateTime.utc_now()
    #   date_time = %{date_time | microsecond: {0, 0}}
    #   # DateTime.to_iso8601(date_time, :basic)
    #   DateTime.to_iso8601(date_time)
    # end

    def parse_args(argv) do
      {args, _, _} = OptionParser.parse(argv)

      app_name = Mix.Project.config()[:app] |> Atom.to_string()
      version = Mix.Project.config()[:version]
      deploy_base = Mix.Project.config()[:deploy_base] || "/opt"
      deploy_dir = Mix.Project.config()[:deploy_dir] || Path.join(deploy_base, app_name)

      tarball =
        Path.join([
          "..",
          "..",
          "_build",
          to_string(Mix.env()),
          "rel",
          app_name,
          "releases",
          version,
          "#{app_name}.tar.gz"
        ])

      defaults = %{
        app_name: app_name,
        deploy_base: deploy_base,
        deploy_dir: deploy_dir,
        tarball: tarball,
        new: false,
        version: version,
        upgrade: false
      }

      Enum.reduce(args, defaults, fn arg, config ->
        case arg do
          {:verbosity, verbosity} ->
            %{config | :verbosity => String.to_atom(verbosity)}

          {key, value} ->
            Map.put(config, key, value)
        end
      end)
    end
  end
end

defmodule Mix.Tasks.Deploy.Local.Rollback do
  @shortdoc "Roll back to previous release"

  @moduledoc """
  This task updates the current symlink to point to the previous release directory.
  """

  use Mix.Task

  def run(args) do
    config = Mix.Tasks.Deploy.Local.parse_args(args)
    dirs = config.release_base |> File.ls!() |> Enum.sort() |> Enum.reverse()
    rollback(dirs, config)
  end

  def rollback([_current, prev | _rest], config) do
    release_dir = Path.join(config.release_base, prev)
    remove_current_link(config)
    IO.puts("Making link from #{release_dir} to #{config.current_link}")
    File.ln_s(release_dir, config.current_link)
  end

  def rollback(dirs, _config) do
    IO.puts("Nothing to roll back to: releases = #{inspect(dirs)}")
  end

  def remove_current_link(config) do
    case File.read_link(config.current_link) do
      {:ok, target} ->
        IO.puts("Removing link from #{target} to #{config.current_link}")
        :ok = File.rm(config.current_link)

      {:error, _reason} ->
        IO.puts("No current link #{config.current_link}")
    end
  end
end
