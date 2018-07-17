defmodule Bot.Handler.Command.Image do
  @behaviour Bot.Handler.Command

  alias Bot.Handler.Command
  alias __MODULE__

  def aliases(), do: ["picture"]

  def process(message, args) when length(args) <= 2 do
    Command.run(Image.Konachan, message, args)

    nil
  end

  def process(message, args) when length(args) <= 5 do
    case :rand.uniform(2) do
      1 -> Command.run(Image.Donmai, message, args)
      2 -> Command.run(Image.Konachan, message, args)
    end

    nil
  end

  def process(_message, _args) do
    {:respond, "The maximum amount of tags you can specify is 5."}
  end
end