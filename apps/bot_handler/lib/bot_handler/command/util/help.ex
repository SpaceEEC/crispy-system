defmodule Bot.Handler.Command.Util.Help do
  alias Bot.Handler.Command
  @behaviour Command

  alias Bot.Handler.Command.Commands
  alias Bot.Handler.Config.Guild

  def usages(), do: ["<Command>"]
  def examples(), do: ["", "invite"]
  def description(), do: "Display a list of commands, or help for a specific one."

  def fetch(_message, []), do: {:ok, nil}

  def fetch(_message, [command | _]) do
    case command |> String.downcase() |> Command.resolve() do
      nil ->
        {:respond, "Could not find such a command."}

      command ->
        {:ok, command}
    end
  end

  def process(_message, nil) do
    fields =
      Commands.commands()
      |> Map.values()
      |> Enum.group_by(
        fn mod -> mod |> Module.split() |> Enum.take(-2) |> List.first() end,
        fn mod -> mod |> Module.split() |> List.last() end
      )
      |> Enum.map(fn {group, names} ->
        %{
          title: "❯ #{group}",
          value: "`#{names |> Enum.join("`, `")}`"
        }
      end)

      embed = %{
        title: "❯ Command List",
        description: "A list of all commands.\nUse `help <Command>` for more info for a specific command.",
        fields: fields
      }

      {:respond, [embed: embed]}
  end

  def process(%{guild_id: guild_id}, command) do
    prefix = Guild.get!(guild_id, "prefix", Command.get_prefix())

    name = Module.split(command) |> List.last() |> to_string()
    examples = if(function_exported?(command, :examples, 0), do: command.examples(), else: [""])
    usages = if(function_exported?(command, :usages, 0), do: command.usages(), else: [""])


    fields = [
      %{title: "❯ Usage(s)", value: "`#{prefix}#{name} #{usages |> Enum.join("`\n`#{prefix}#{name} ")}`", inline: true},
      %{
        title: "❯ Example(s)",
        value: "`#{prefix}#{name} #{examples |> Enum.join("`\n`#{prefix}#{name} ")}`",
        inline: true
      }
    ]

    fields =
      if function_exported?(command, :aliases, 0) do
        [
          %{title: "❯ Alias(es)", value: command.aliases() |> Enum.join("\n")}
          | fields
        ]
      else
        fields
      end

    embed = %{
      title: name,
      description: command.description(),
      fields: fields
    }

    {:respond, [embed: embed]}
  end
end
