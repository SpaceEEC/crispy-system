defmodule Bot.Handler.Locale.EN do
  @moduledoc false

  @behaviour Bot.Handler.Locale

  @localization %{
    # Meta
    LOC_DESC_LANGUAGE: "Set or display the language.",
    LOC_DESC_PREFIX: "See, set, or remove the current server prefix.",
    LOC_DESC_VLOG: "See, set, or remove the current voice log channel.",
    LOC_DESC_DONMAI: """
    Fetches a random picture from https://safebooru.donmai.us/, optionally with tags to search with.
    """,
    LOC_DESC_IMAGE: """
    Fetches a random picture from https://safebooru.donmai.us/ or https://konachan.net/, optionally with tags to search with.
    """,
    LOC_DESC_KONACHAN: """
    Fetches a random picture from https://konachan.net/, optionally with tags to search with.
    """,
    LOC_DESC_AVATAR: "Displays the avatar of the mentioned user.",
    LOC_DESC_URBAN: "Displays the urban definition of a term.",
    LOC_DESC_JOIN: "Commands the bot to join your channel.",
    LOC_DESC_LEAVE: "Commands the bot to leave your channel.",
    LOC_DESC_LOOP: "Enabled, disabled, or shows the current state of the queue.",
    LOC_DESC_NP: "Displays the currently played song.",
    LOC_DESC_PAUSE: "Pauses the currently played song.",
    LOC_DESC_PLAY: "Starts a song or queues it up.",
    LOC_DESC_QUEUE: "Shows the currently queued songs.",
    LOC_DESC_RESUME: "Resumes the currently paused song",
    LOC_DESC_SAVE: "Sents you a dm containing the currently played song, for your later use.",
    LOC_DESC_SHUFFLE: "Shuffles the queue.",
    LOC_DESC_SKIP: "Skips the currently played song.",
    LOC_DESC_STOP: "Stops the currently played song, clears the queue, and disconnects the bot.",
    LOC_DESC_HELP: "Display a list of commands, or help for a specific one.",
    LOC_DESC_INVITE: "Invite the bot to your server.",
    LOC_DESC_UPTIME: "Gets the uptime of the nodes.",

    # General
    LOC_GUILD_ONLY: "That command may not be used in dms.",
    LOC_SENT_DM: "Sent you a dm.",
    LOC_FAILED_DM: """
    I could not dm you.
    Did you disable dms or perhaps block me?
    """,
    LOC_NOTHING_FOUND: "Could not find anything.",
    LOC_USER_NOT_FOUND: "Could not find that user.",
    LOC_NO_RESULTS: "No results.",
    LOC_NOTHING_FOUND_URL: """
    Could not find anything.
    Maybe made a typo? [Search]({{url}})
    """,

    # Prefix
    LOC_PREFIX_PERMS:
      "You do not have the manage guild permission, required to set the server prefix.",
    LOC_PREFIX_CURRENT: "The current server prefix is ``{{prefix}}``.",
    LOC_PREFIX_CHANGED: "The server prefix changed from ``{{old}}`` to ``{{new}}``.",
    LOC_PREFIX_SET: "Set the server prefix to ``{{new}}``.",

    # RemovePrefix
    LOC_REMOVEPREFIX_PERMS:
      "You do not have the required manage guild permission to remove the prefix.",
    LOV_REMOVEPREFIX_NONE: "No custom prefix was set, the default one is ``{{default}}``.",
    LOV_REMOVEPREFIX_REMOVED: "Custom prefix removed, now using default one: ``{{default}}``.",

    # SetLang
    LOC_LANG_PERMS: "You do not have the required manage guild permission to set the language.",
    LOC_LANG_CURRENT: "The current language is ``{{lang}}``.",
    LOC_LANG_SET: "Language set to ``{{new}}``.",
    LOC_LANG_INVALID: """
    No such supported language ``{{lang}}``.
    Supported languages:
    {{supported}}
    """,

    # VlogChannel
    LOC_VLOG_PERMS:
      "You do not have the required manage guild permission to see or modify the voice log channel.",
    LOC_VLOG_NO_CHANNEL: "Could not find a channel with the id {{id}} from <\#{{id}}>.",
    LOG_VLOG_WRONG_GUILD: "The requested channel is not in this guild.",
    LOG_VLOG_NOT_TEXT_CHANNEL: "{{channel}} is not a text channel.",
    LOG_VLOG_INVALID_ARGS: "Pass either nothing, \"remove\", or a channel mention.",
    LOG_VLOG_NO_SETUP: "No voice log channel was set up.",
    LOG_VLOG_SETUP: "The current voice log channel is <\#{{id}}>.",
    LOG_VLOG_REMOVED: "Removed the set voice log channel from the configuration.",
    LOG_VLOG_NOTHING_REMOVED: "No voice log channel was set up.",
    LOG_VLOG_SET_CHANNEL: "Set the voice log channel to <\#{{id}}>.",

    # Image
    LOC_IMAGE_MAX_TAGS: "The maximum amount of tags you can specify is {{max}}.",
    LOC_IMAGE_ERROR: "An error occured while searching.",

    # Urban
    LOC_URBAN_NO_QUERY: "You need to tell me what you want to look up.",
    LOC_URBAN_FOOTER: "{{content}} | Definition {{number}} out of {{total}}.",
    LOC_URBAN_EXAMPLE: "❯ Example",
    LOC_URBAN_DEFINITION: "❯ Definition",
    LOC_URBAN_ERROR: """
    An error occured while searching. [Search](url)
    """,

    # Help
    LOC_HELP_NO_SUCH_COMMAND: "Could not find such a command.",
    LOC_HELP_EMBED_TITLE: "❯ Command List",
    LOC_HELP_EMBED_DESCRIPTION: """
    A list of all commands.
    Use `help <Command>` for more info for a specific command.
    """,
    LOC_HELP_USAGES: "❯ Usage(s)",
    LOC_HELP_EXAMPLES: "❯ Example(s)",
    LOC_HELP_ALIASES: "❯ Alias(es)",

    # Invite
    LOC_INVITE: "Invite",
    LOC_INVITE_DESCRIPTION: """
    To invite me to your server click [this]({{url}}) link.
    **Note**: You need the **Manage Server** permission to add me there.
    \u200b
    """,

    # Uptime
    LOC_UPTIME: """
    **Uptime:**
    ```asciidoc
    {{content}}
    ```
    """,

    # Music
    LOC_MUSIC_NO_QUERY: "You have to give me a url, or something to search for.",
    LOC_MUSIC_NOT_PLAYING_HERE: "I am currently not playing anything here.",
    LOC_MUSIC_ALREADY_PAUSED: "The player is already paused.",
    LOC_MUSIC_PAUSED: "Paused the player.",
    LOC_MUSIC_RESUMED: "Resumed the player.",
    LOC_MUSIC_ALREADY_PLAYING: "The player is already playing.",
    LOC_MUSIC_QUEUE_EMPTY: "The queue looks empty to me",
    LOC_MUSIC_JUST_SKIPPED: "You just skipped `{{title}}` (`{{time}}`), such a shame.",
    LOC_MUSIC_STOPPED: "Congratulations, you just killed the party 🎉.",
    LOC_MUSIC_SHUFFLED: "Shuffled the playlist.",
    LOC_MUSIC_LOOP_ENABLED: "Loop is enabled.",
    LOC_MUSIC_LOOP_DISABLED: "Loop is disabled.",
    LOC_MUSIC_LEAVING: "Leaving you...",
    LOC_MUSIC_JOINING: "Joining you...",
    LOC_MUSIC_NOT_CONNECTED: "You don't look connected to me.",

    # embeds
    LOC_MUSIC_SAVE: "saved, just for you.",
    LOC_MUSIC_PLAY: "is now being played.",
    LOC_MUSIC_ADD: "has been added.",
    LOC_MUSIC_NP: "currently playing.",
    LOC_MUSIC_EMBED_LOOP: """
    **Loop is enabled**
    {{prefix}} [{{title}}]({{uri}})
    Length: {{length}}
    """,
    LOC_MUSIC_EMBED: """
    {{prefix}} [{{title}}]({{uri}})
    Length: {{length}}
    """,

    # queue
    LOC_QUEUE_TITLE: "Queued up Songs: {{songs}} | Queue length: {{length}}",
    LOC_QUEUE_MUSIC_EMBED_LOOP: """
    **Loop is enabled**
    **Currently playing**
    [{{title}}]({{uri}})
    **Time**: (`{{current}}` / `{{length}}`)

    **Queue**:
    {{songs}}
    """,
    LOC_QUEUE_MUSIC_EMBED: """
    **Currently playing**
    [{{title}}]({{uri}})
    **Time**: (`{{current}}` / `{{length}}`)

    **Queue**:
    {{songs}}
    """,
    LOC_QUEUE_FOOTER: "Page {{page}} of {{pages}}",

    # now playing
    LOC_NP_EMBED_LOOP: """
    **Loop is enabled**
    {{prefix}} [{{title}}]({{uri}})
    **Progress**: **[{{played_bars}}](https://crux.randomly.space/){{unplayed_bars}}** (`{{position}}` / `{{length}}`)
    """,
    LOC_NP_EMBED: """
    {{prefix}} [{{title}}]({{uri}})
    **Progress**: **[{{played_bars}}](https://crux.randomly.space/){{unplayed_bars}}** (`{{position}}` / `{{length}}`)
    """,

    # Music util
    LOC_MUSIC_SELF_DISCONNECTED: "I am not connected to a voice channel here.",
    LOC_MUSIC_YOU_DISCONNECTED: "You are not connected to a voice channel here.",
    LOC_MUSIC_DIFFERENT_CHANNEL: "You are in a different channel."
  }

  def get_string(key) do
    Map.get(@localization, key) || raise "Unsupported key #{key} (#{__MODULE__})"
  end
end
