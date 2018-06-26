defmodule Bot.Handler.Command.Commands do
  # Generated 2018-06-26T17:46:52.676000Z
  @commands %{
    "eval" => Bot.Handler.Command.Eval,
    "join" => Bot.Handler.Command.Join,
    "leave" => Bot.Handler.Command.Leave,
    "loop" => Bot.Handler.Command.Loop,
    "nowplaying" => Bot.Handler.Command.NowPlaying,
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
  @aliases %{"np" => Bot.Handler.Command.NowPlaying}

  @spec commands() :: %{required(String.t()) => module()}
  def commands(), do: @commands
  @spec aliases() :: %{required(String.t()) => module()}
  def aliases(), do: @aliases
end
