defmodule Mix.Tasks.Commands do
  @moduledoc false

  use Mix.Task

  @template ~S"""
  defmodule Bot.Handler.Command.Commands do
    @moduledoc false

    # Generated #{generated}
    @commands #{commands}
    @aliases #{aliases}

    @spec commands() :: %{required(String.t()) => module()}
    def commands(), do: @commands
    @spec aliases() :: %{required(String.t()) => module()}
    def aliases(), do: @aliases
  end
  """

  # credo:disable-for-next-line Credo.Check.Refactor.ABCSize
  def run(_args) do
    [commands, aliases] =
      [".", "lib", "bot_handler", "command", "*", "*.ex"]
      |> Path.join()
      |> Path.wildcard()
      |> Enum.map(&correct_path/1)
      |> Enum.reduce([%{}, %{}], fn name, [cmds, aliases] ->
        module = Module.concat(Bot.Handler.Command, name)

        if Code.ensure_loaded?(module) do
          name =
            name
            |> String.split(".")
            |> List.last()
            |> String.downcase()

          cmds = Map.put(cmds, name, module)

          new_aliases =
            if function_exported?(module, :aliases, 0) do
              module.aliases()
              |> Map.new(&{&1, module})
            else
              %{}
            end

          aliases = Map.merge(aliases, new_aliases, &raise_on_duplicate/3)

          [cmds, aliases]
        else
          Mix.shell().info("Skipping #{inspect(module)} since it was not found.")

          [cmds, aliases]
        end
      end)
      |> Enum.map(&inspect(&1, pretty: true))
      |> Enum.map(&String.replace(&1, "\n", "\n  "))

    content =
      @template
      |> String.replace("\#{generated}", DateTime.utc_now() |> DateTime.to_iso8601())
      |> String.replace("\#{commands}", commands)
      |> String.replace("\#{aliases}", aliases)

    [".", "lib", "bot_handler", "command", "commands.ex"]
    |> Path.join()
    |> File.write!(content)
  end

  defp correct_path("lib/bot_handler/command/" <> rest) do
    [file | path] =
      rest
      |> Path.split()
      |> Enum.reverse()

    file = file |> Path.basename(".ex") |> Macro.camelize()
    [head | _tails] = path = Enum.map(path, &String.capitalize/1)

    if(head == file, do: path, else: [file | path])
    # credo:disable-for-next-line Credo.Check.Refactor.PipeChainStart
    |> Enum.reverse()
    |> Enum.join(".")
  end

  defp raise_on_duplicate(alias_, mod1, mod2) do
    raise "Duplicated alias \"#{alias_}\" for modules: \"#{inspect(mod1)}\" and \"#{inspect(mod2)}\"!"
  end
end
