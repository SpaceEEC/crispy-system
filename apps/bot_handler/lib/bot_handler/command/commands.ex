defmodule Bot.Handler.Command.Commands do
  # Generated 2018-07-16T14:10:26.725000Z
  @commands %{
    "avatar" => Bot.Handler.Command.Misc.Avatar,
    "donmai" => Bot.Handler.Command.Image.Donmai,
    "eval" => Bot.Handler.Command.Util.Eval,
    "image" => Bot.Handler.Command.Image,
    "invite" => Bot.Handler.Command.Util.Invite,
    "join" => Bot.Handler.Command.Music.Join,
    "konachan" => Bot.Handler.Command.Image.Konachan,
    "leave" => Bot.Handler.Command.Music.Leave,
    "loop" => Bot.Handler.Command.Music.Loop,
    "nowplaying" => Bot.Handler.Command.Music.NowPlaying,
    "pause" => Bot.Handler.Command.Music.Pause,
    "ping" => Bot.Handler.Command.Util.Ping,
    "play" => Bot.Handler.Command.Music.Play,
    "queue" => Bot.Handler.Command.Music.Queue,
    "resume" => Bot.Handler.Command.Music.Resume,
    "save" => Bot.Handler.Command.Music.Save,
    "shuffle" => Bot.Handler.Command.Music.Shuffle,
    "skip" => Bot.Handler.Command.Music.Skip,
    "stop" => Bot.Handler.Command.Music.Stop,
    "uptime" => Bot.Handler.Command.Util.Uptime,
    "urban" => Bot.Handler.Command.Misc.Urban
  }
  @aliases %{
    "np" => Bot.Handler.Command.Music.NowPlaying,
    "picture" => Bot.Handler.Command.Image
  }

  @spec commands() :: %{required(String.t()) => module()}
  def commands(), do: @commands
  @spec aliases() :: %{required(String.t()) => module()}
  def aliases(), do: @aliases
end
