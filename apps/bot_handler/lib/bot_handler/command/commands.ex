defmodule Bot.Handler.Command.Commands do
  @moduledoc false

  # Generated 2018-10-15T17:17:47.039000Z
  @commands %{
    "anime" => Bot.Handler.Command.Misc.Anime,
    "avatar" => Bot.Handler.Command.Misc.Avatar,
    "character" => Bot.Handler.Command.Misc.Character,
    "donmai" => Bot.Handler.Command.Image.Donmai,
    "eval" => Bot.Handler.Command.Util.Eval,
    "help" => Bot.Handler.Command.Util.Help,
    "image" => Bot.Handler.Command.Image,
    "invite" => Bot.Handler.Command.Util.Invite,
    "join" => Bot.Handler.Command.Music.Join,
    "konachan" => Bot.Handler.Command.Image.Konachan,
    "language" => Bot.Handler.Command.Config.Language,
    "leave" => Bot.Handler.Command.Music.Leave,
    "loop" => Bot.Handler.Command.Music.Loop,
    "manga" => Bot.Handler.Command.Misc.Manga,
    "nowplaying" => Bot.Handler.Command.Music.NowPlaying,
    "pause" => Bot.Handler.Command.Music.Pause,
    "ping" => Bot.Handler.Command.Util.Ping,
    "play" => Bot.Handler.Command.Music.Play,
    "prefix" => Bot.Handler.Command.Config.Prefix,
    "queue" => Bot.Handler.Command.Music.Queue,
    "removeprefix" => Bot.Handler.Command.Config.RemovePrefix,
    "resume" => Bot.Handler.Command.Music.Resume,
    "save" => Bot.Handler.Command.Music.Save,
    "shuffle" => Bot.Handler.Command.Music.Shuffle,
    "skip" => Bot.Handler.Command.Music.Skip,
    "stop" => Bot.Handler.Command.Music.Stop,
    "uptime" => Bot.Handler.Command.Util.Uptime,
    "urban" => Bot.Handler.Command.Misc.Urban,
    "vlogchannel" => Bot.Handler.Command.Config.VlogChannel
  }
  @aliases %{
    "char" => Bot.Handler.Command.Misc.Character,
    "lang" => Bot.Handler.Command.Config.Language,
    "np" => Bot.Handler.Command.Music.NowPlaying,
    "picture" => Bot.Handler.Command.Image,
    "q" => Bot.Handler.Command.Music.Queue
  }

  @spec commands() :: %{required(String.t()) => module()}
  def commands(), do: @commands
  @spec aliases() :: %{required(String.t()) => module()}
  def aliases(), do: @aliases
end
