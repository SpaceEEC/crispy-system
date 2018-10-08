defmodule Bot.Handler.Command.Image do
  @moduledoc false

  @behaviour Bot.Handler.Command

  alias Bot.Handler.Command
  alias __MODULE__

  def usages(), do: ["<...Tags>"]
  def examples(), do: ["komeiji_satori", "touhou long_sleeves"]

  def description(), do: :LOC_DESC_IMAGE

  def aliases(), do: ["picture"]

  def process(message, %{args: args} = info) when length(args) <= 5 do
    case :rand.uniform(2) do
      1 -> Command.run(Image.Donmai, message, info)
      2 -> Command.run(Image.Konachan, message, info)
    end

    nil
  end

  def process(message, %{args: args} = info) when length(args) <= 2 do
    Command.run(Image.Konachan, message, info)

    nil
  end

  def process(_message, _args) do
    {:respond, {:LOC_IMAGE_MAX_TAGS, [max: 5]}}
  end
end
