defmodule Mix.Tasks.Commands do
  use Mix.Task

  @template ~S"""
  defmodule Bot.Handler.Command.Commands do
    # Generated #{generated}
    @commands #{commands}
    @aliases #{aliases}

    @spec commands() :: %{required(String.t()) => module()}
    def commands(), do: @commands
    @spec aliases() :: %{required(String.t()) => module()}
    def aliases(), do: @aliases
  end
  """

  def run(_args) do
    [commands, aliases] =
      [".", "lib", "bot_handler", "command", "*.ex"]
      |> Path.join()
      |> Path.wildcard()
      |> Enum.map(fn file ->
        file
        |> Path.basename(".ex")
        |> String.split("_")
        |> Enum.map_join("", &String.capitalize/1)
      end)
      |> Enum.filter(fn name ->
        name != "Commands" && Module.concat(Bot.Handler.Command, name) |> Code.ensure_loaded?()
      end)
      |> Enum.reduce([%{}, %{}], fn name, [cmds, aliases] ->
        module = Module.concat(Bot.Handler.Command, name)
        name = String.downcase(name)

        cmds = Map.put(cmds, name, module)

        c_aliases =
          if function_exported?(module, :aliases, 0) do
            module.aliases()
            |> Map.new(&{&1, module})
          else
            %{}
          end

        aliases = Map.merge(aliases, c_aliases, &raise_duplicate/3)

        [cmds, aliases]
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

  defp raise_duplicate(alias_, mod1, mod2) do
    raise "Duplicated alias \"#{alias_}\" for modules: \"#{inspect(mod1)}\" and \"#{inspect(mod2)}\"!"
  end
end
