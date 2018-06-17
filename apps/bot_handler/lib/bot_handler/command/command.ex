defmodule Bot.Handler.Command do
  @callback inhibit(Crux.Structs.Message, [String.t()]) :: boolean()
  @callback handle(Crux.Structs.Message, [String.t()]) :: term()

  @optional_callbacks inhibit: 2

  @prefix "ß"
  @commands %{
    # TODO: Aliases
    "eval" => Bot.Handler.Command.Eval,
    "join" => Bot.Handler.Command.Join,
    "leave" => Bot.Handler.Command.Leave,
    "loop" => Bot.Handler.Command.Loop,
    "np" => Bot.Handler.Command.NowPlaying,
    "pause" => Bot.Handler.Command.Pause,
    "ping" => Bot.Handler.Command.Ping,
    "play" => Bot.Handler.Command.Play,
    "queue" => Bot.Handler.Command.Queue,
    "resume" => Bot.Handler.Command.Resume,
    "shuffle" => Bot.Handler.Command.Shuffle,
    "skip" => Bot.Handler.Command.Skip,
    "stop" => Bot.Handler.Command.Stop,
    "uptime" => Bot.Handler.Command.Uptime
  }

  def handle(%{content: @prefix <> content} = message) do
    with [command | args] <- String.split(content, ~r/ +/, parts: :infinity),
         command <- String.downcase(command),
         %{^command => mod} <- @commands,
         true <- inhibit_command(mod, message, args) do
      mod.handle(message, args)
    end
  end

  def handle(_message), do: nil

  defp inhibit_command(mod, message, args) do
    if Keyword.has_key?(mod.__info__(:functions), :inhibit) do
      mod.inhibit(message, args)
    else
      true
    end
  end
end
