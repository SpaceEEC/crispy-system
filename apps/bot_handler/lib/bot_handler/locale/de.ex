defmodule Bot.Handler.Locale.DE do
  @moduledoc false

  @behaviour Bot.Handler.Locale

  @localization %{
    # Meta
    LOC_DESC_LANGUAGE: "Setze oder zeige die aktuelle Sprache.",
    LOC_DESC_PREFIX: "Setze, zeige oder entferene den Serverprefix.",
    LOC_DESC_VLOG: "Setze, zeige oder entferene den voice log channel.",
    LOC_DESC_DONMAI: """
    Rufe ein zufälliges Bild von https://safebooru.donmai.us/ ab, optional mit Konkretisierung mithilfe von Tags.
    """,
    LOC_DESC_IMAGE: """
    Rufe ein zufälliges Bild von hhttps://safebooru.donmai.us/ oder https://konachan.net/ ab, optional mit Konkretisierung mithilfe von Tags.
    """,
    LOC_DESC_KONACHAN: """
    Rufe ein zufälliges Bild von https://konachan.net/ ab, optional mit Konkretisierung mithilfe von Tags.
    """,
    LOC_DESC_AVATAR: "Zeigt das Avatar des erwähnten Nutzers an.",
    LOC_DESC_URBAN: "Zeigt die \"UrbanDefintion\" eines Begriffes an. (Englisch)",
    LOC_DESC_JOIN: "Ruft den Bot zu dem aktuellen Channel.",
    LOC_DESC_LEAVE: "Verstößt den Bot vom dem aktuellen Channel.",
    LOC_DESC_LOOP: "Aktiviert, deaktiviert do Schleife, oder zeigt den Status dieser an.",
    LOC_DESC_NP: "Zeigt das aktuel gespielte Lied an.",
    LOC_DESC_PAUSE: "Pausiert das aktuel gespielte Lied.",
    LOC_DESC_PLAY: "Startet ein Lied oder fügt dieses der Warteschlange hinzu.",
    LOC_DESC_QUEUE: "Zeigt die sich aktuel in der Warteschlange befindlichen Lieder an.",
    LOC_DESC_RESUME: "Setzt die Wiedergabe des aktuel pausierten Liedes fort.",
    LOC_DESC_SAVE:
      "Sendet eine Direktnachricht mit dem aktuel gespieltem Lied für den späteren Gebrauch.",
    LOC_DESC_SHUFFLE: "Mischt die Warteschlange durch.",
    LOC_DESC_SKIP: "Überspringt das aktuel gespielte Lied.",
    LOC_DESC_STOP:
      "Stopt das aktuelle Lied, leert die Warteschlange, und beendet die Verbindung.",
    LOC_DESC_HELP: "Zeigt die Liste von Befehlen, oder Hilfe für einen bestimment Befehl, an.",
    LOC_DESC_INVITE: "Lade den Bot zu deinem Server ein.",
    LOC_DESC_UPTIME: "Zeige die Laufzeit der Nodes an.",

    # General
    LOC_GUILD_ONLY: "Dieser Befehl kann nicht in Direktnachrichten verwendent werden.",
    LOC_SENT_DM: "Habe dir eine Direktnachricht zukommen lassen.",
    LOC_FAILED_DM: """
    Meine Direktnachricht konnte dich nicht erreichen.
    Hast du diese vielleicht deaktiviert, oder mich blockiert?
    """,
    LOC_NOTHING_FOUND: "Konnte nichts finden.",
    LOC_USER_NOT_FOUND: "Konnte keinen solchen Nutzer finden.",
    LOC_NO_RESULTS: "Keine Resultate.",
    LOC_NOTHING_FOUND_URL: """
    Konnte nichts finden.
    Vielleicht vertippt? [Suche]({{url}})
    """,

    # Prefix
    LOC_PREFIX_PERMS:
      "Du scheinst nicht über die benötigten \"Server Verwalten\" Rechte, um den Serverprefix zu verändern, zu verfügen.",
    LOC_PREFIX_CURRENT: "Bei dem aktuellen Serverprefix handelt es sich um ``{{prefix}}``.",
    LOC_PREFIX_CHANGED: "Lies den Prefix von ``{{old}}`` zu ``{{new}}`` ändern.",
    LOC_PREFIX_SET: "Lies den Prefix zu ``{{new}}`` ändern.",

    # RemovePrefix
    LOC_REMOVEPREFIX_PERMS:
      "Du scheinst nicht über die benötigten \"Server Verwalten\" Rechte, um den Serverprefix zu entfernen, zu verfügen.",
    LOV_REMOVEPREFIX_NONE: "Kein Serverprefix gesetzt, der Standarprefix ist ``{{default}}``.",
    LOV_REMOVEPREFIX_REMOVED: "Serverprefix entfernt, Standardprefix gesetzt: ``{{default}}``.",

    # SetLang
    LOC_LANG_PERMS:
      "Du scheinst nicht über die benötigten \"Server Verwalten\" Rechte, um die Sprache zu ändern, zu verfügen.",
    LOC_LANG_CURRENT: "Bei der aktuellen Sprache handelt es sich um ``{{lang}}``.",
    LOC_LANG_SET: "Lies die Sprache auf ``{{new}}`` setzen.",
    LOC_LANG_INVALID: """
    Die Sprache ``{{lang}}`` existiert entweder nicht, oder wird nicht unterstützt.
    Unterstütze Sprachen:
    {{supported}}
    """,

    # VlogChannel
    LOC_VLOG_PERMS:
      "Du scheinst nicht über die benötigten \"Server Verwalten\" Rechte, um den voice log channel zu sehen, oder zu verändern, zu verfügen.",
    LOC_VLOG_NO_CHANNEL: "Konnte keinen Channel mit der id {{id}} ausfindig machen. (<\#{{id}}>)",
    LOG_VLOG_WRONG_GUILD: "Dieser Channel befindet sich in einem anderen Server.",
    LOG_VLOG_NOT_TEXT_CHANNEL: "{{channel}} ist kein Textchannel.",
    LOG_VLOG_INVALID_ARGS: "Übergebe entweder nichts, \"remove\", oder eine Channelerwähnung.",
    LOG_VLOG_NO_SETUP: "Es ist im moment kein voice log channel gesetzt.",
    LOG_VLOG_SETUP: "Bei dem aktuellen voice log channel handelt es sich um <\#{{id}}>.",
    LOG_VLOG_REMOVED: "Lies den voic log channel von der Konfiguration entfernen.",
    LOG_VLOG_NOTHING_REMOVED: "Kein voice log channel gesetzt, nichts zu entfernen.",
    LOG_VLOG_SET_CHANNEL: "Lies <\#{{id}}> als voice log channel setzen.",

    # Image
    LOC_IMAGE_MAX_TAGS: "Die maximale Anzahl an verwendbaren Tags beträgt {{max}}",
    LOC_IMAGE_ERROR: "Ein Fehler trat bei der Suche auf.",

    # Urban
    LOC_URBAN_NO_QUERY: "Das Suchen ohne Ziel ist in diesem Fall aussichtslos.",
    LOC_URBAN_FOOTER: "{{content}} | Definition {{number}} von {{total}}",
    LOC_URBAN_EXAMPLE: "❯ Beispiel",
    LOC_URBAN_DEFINITION: "❯ Definition",
    LOC_URBAN_ERROR: """
    Ein Fehler trat bei der Suche auf. [Suche](url)
    """,

    # Help
    LOC_HELP_NO_SUCH_COMMAND: "Ein solcher Befehl war nicht auffindbar.",
    LOC_HELP_EMBED_TITLE: "❯ Befehle",
    LOC_HELP_EMBED_DESCRIPTION: """
    Eine Liste aller Befehle.
    Nutze `help <Befehl>` für mehr Informationen bezüglich eines spezifischen Befehls.
    """,
    LOC_HELP_USAGES: "❯ Anwendung(en)",
    LOC_HELP_EXAMPLES: "❯ Beispiel(e)",
    LOC_HELP_ALIASES: "❯ Alias(se)",

    # Invite
    LOC_INVITE: "Einladung",
    LOC_INVITE_DESCRIPTION: """
    Um mich zu deinem Server einzuladen klicke [diesen]({{url}}) Link.
    **Hinweis**: Du benötigst dazu **Server Verwalten** Rechte dort.
    \u200b
    """,

    # Uptime
    LOC_UPTIME: """
    **Laufzeit:**
    ```asciidoc
    {{content}}
    ```
    """,

    # Music
    LOC_MUSIC_NO_QUERY: "Das Suchen ohne Ziel ist in diesem Fall aussichtslos.",
    LOC_MUSIC_NOT_PLAYING_HERE: "Im Moment wird hier nichts gespielt.",
    LOC_MUSIC_ALREADY_PAUSED: "Im Moment ist hier pause.",
    LOC_MUSIC_PAUSED: "Pausierte.",
    LOC_MUSIC_RESUMED: "Fuhr fort.",
    LOC_MUSIC_ALREADY_PLAYING: "Es wird bereits gespielt, fortfahren erscheint mir nicht klug.",
    LOC_MUSIC_QUEUE_EMPTY: "Die Warteschlange scheint leer zu sein.",
    LOC_MUSIC_JUST_SKIPPED: "´{{title}}` (`{{time}}`) wurde übersprungen, eine Schande.",
    LOC_MUSIC_STOPPED: "Stoppte die Wiedergabe.",
    LOC_MUSIC_SHUFFLED: "Warteschlange wurde durchgemischt.",
    LOC_MUSIC_LOOP_ENABLED: "Schleife ist aktiviert.",
    LOC_MUSIC_LOOP_DISABLED: "Schleife ist deaktiviert.",
    LOC_MUSIC_LEAVING: "Verlasse deinen Channel...",
    LOC_MUSIC_JOINING: "Trete dir bei...",
    LOC_MUSIC_NOT_CONNECTED: "Du scheinst mir hier nicht wirklich verbunden zu sein.",

    # embeds
    LOC_MUSIC_SAVE: "gesichert, nur für dich.",
    LOC_MUSIC_PLAY: "wird jetzt gespielt.",
    LOC_MUSIC_ADD: "wurde hinzugefügt.",
    LOC_MUSIC_NP: "wird im moment gespielt.",
    LOC_MUSIC_EMBED_LOOP: """
    **Schleife ist aktiv**
    {{prefix}} [{{title}}]({{uri}})
    Dauer: {{length}}
    """,
    LOC_MUSIC_EMBED: """
    {{prefix}} [{{title}}]({{uri}})
    Dauer: {{length}}
    """,

    # queue
    LOC_QUEUE_TITLE: "Lieder in der Warteschlange: {{songs}} | Dauer insgesamt: {{length}}",
    LOC_QUEUE_MUSIC_EMBED_LOOP: """
    **Schleife ist aktiv**
    **Wird gerade gespielt**
    [{{title}}]({{uri}})
    **Zeit**: (`{{current}}` / `{{length}}`)

    **Warteschlange**:
    {{songs}}
    """,
    LOC_QUEUE_MUSIC_EMBED: """
    **Wird gerade gespielt**
    [{{title}}]({{uri}})
    **Zeit**: (`{{current}}` / `{{length}}`)

    **Warteschlange**:
    {{songs}}
    """,
    LOC_QUEUE_FOOTER: "Seite {{page}} von {{pages}}",

    # now playing
    LOC_NP_EMBED_LOOP: """
    **Schleife ist aktiv**
    {{prefix}} [{{title}}]({{uri}})
    **Fortschritt**: **[{{played_bars}}](https://crux.randomly.space/){{unplayed_bars}}** (`{{position}}` / `{{length}}`)
    """,
    LOC_NP_EMBED: """
    {{prefix}} [{{title}}]({{uri}})
    **Fortschritt**: **[{{played_bars}}](https://crux.randomly.space/){{unplayed_bars}}** (`{{position}}` / `{{length}}`)
    """,

    # Music util
    LOC_MUSIC_SELF_DISCONNECTED: "Ich befinde mich in keinem Channel.",
    LOC_MUSIC_YOU_DISCONNECTED: "Du befindest dich in keinem Channel.",
    LOC_MUSIC_DIFFERENT_CHANNEL: "Du befindest dich in einem anderen Channel."
  }

  def get_string(key) do
    Map.get(@localization, key) || raise "Unsupported key #{key} (#{__MODULE__})"
  end
end
