defmodule Bot.Handler.Command.Util.Help do
  @moduledoc false

  alias Bot.Handler.Command
  @behaviour Command

  alias Bot.Handler.Command.Commands
  alias Bot.Handler.Config.Guild

  def usages(), do: ["<Command>"]
  def examples(), do: ["", "invite"]
  def description(), do: :LOC_DESC_HELP

  def fetch(_message, %{args: []}), do: {:ok, nil}

  def fetch(_message, %{args: [command | _]}) do
    case command |> String.downcase() |> Command.resolve() do
      nil ->
        {:respond, :LOC_HELP_NO_SUCH_COMMAND}

      command ->
        {:ok, command}
    end
  end

  def process(_message, nil) do
    fields =
      Commands.commands()
      |> Map.values()
      |> Enum.group_by(
        fn mod ->
          mod
          |> Module.split()
          |> Enum.take(-2)
          |> case do
            ["Command", group] -> group
            [group, _name] -> group
          end
        end,
        fn mod -> mod |> Module.split() |> List.last() end
      )
      |> Enum.map(fn {group, names} ->
        %{
          name: "❯ #{group}",
          value: "`#{names |> Enum.join("`, `")}`"
        }
      end)

    embed = %{
      title: :LOC_HELP_EMBED_TITLE,
      description: :LOC_HELP_EMBED_DESCRIPTION,
      fields: fields
    }

    {:respond, [embed: embed]}
  end

  def process(%{guild_id: guild_id}, command) do
    prefix = Guild.get!(guild_id, "prefix", Command.get_prefix())

    name = command |> Module.split() |> List.last() |> to_string()
    examples = if(function_exported?(command, :examples, 0), do: command.examples(), else: [""])
    usages = if(function_exported?(command, :usages, 0), do: command.usages(), else: [""])

    fields = [
      %{
        name: :LOC_HELP_USAGES,
        value: "`#{prefix}#{name} #{usages |> Enum.join("`\n`#{prefix}#{name} ")}`",
        inline: true
      },
      %{
        name: :LOC_HELP_EXAMPLES,
        value: "`#{prefix}#{name} #{examples |> Enum.join("`\n`#{prefix}#{name} ")}`",
        inline: true
      }
    ]

    fields =
      if function_exported?(command, :aliases, 0) do
        [
          %{name: :LOC_HELP_ALIASES, value: "`#{command.aliases() |> Enum.join("`, `")}`"}
          | fields
        ]
      else
        fields
      end

    embed = %{
      title: "❯ #{name}",
      description: command.description(),
      fields: fields
    }

    {:respond, [embed: embed]}
  end
end
