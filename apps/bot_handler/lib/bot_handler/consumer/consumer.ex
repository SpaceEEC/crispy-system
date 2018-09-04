defmodule Bot.Handler.Consumer do
  def start_link({type, data, shard_id}) do
    Task.start_link(fn -> handle_event(type, data, shard_id) end)
  end

  @spec child_spec(any()) :: Supervisor.child_spec()
  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :temporary
    }
  end

  def handle_event(:READY, _data, _shard_id) do
    unless Process.whereis(Bot.Handler.Lavalink.Connection) do
      Supervisor.start_child(Bot.Handler.Supervisor, Bot.Handler.Lavalink.Connection)
    end
  end

  def handle_event(:VOICE_STATE_UPDATE, {old, new}, _shard_id) do
    Bot.Handler.Lavalink.Connection.forward(new)
    Bot.Handler.VoiceLog.handle(old, new)
  end

  def handle_event(:VOICE_SERVER_UPDATE, data, _shard_id) do
    Bot.Handler.Lavalink.Connection.forward(data)
  end

  def handle_event(:MESSAGE_CREATE, message, _shard_id) do
    Bot.Handler.Command.handle(message)
  end

  def handle_event(_type, _data, _shard_id), do: nil
end
