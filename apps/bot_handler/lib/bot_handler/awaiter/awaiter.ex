defmodule Bot.Handler.Awaiter do
  use GenStage
  alias Bot.Handler.Rpc
  alias __MODULE__

  @spec await(type :: atom(), fun :: (term() -> boolean()), pos_integer() | :infinity) ::
          term() | :timeout
  def await(type, fun, timeout \\ 5000) do
    args = {type, fun, timeout}
    # Work around to use call
    {:ok, pid} = Awaiter.Supervisor.start_child(args)

    try do
      GenStage.call(pid, :register, 6000)
    catch
      :exit, value ->
        value
    end
  end

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  def init({type, fun, timeout}) do
    unless timeout == :infinity do
      :timer.send_after(timeout + 500, :timeout)
    end

    {:consumer, {type, fun, nil}, subscribe_to: Rpc._producers() |> Map.values()}
  end

  # Timed out, shutdown
  def handle_info(:timeout, {_, _, pid} = state) do
    GenServer.reply(pid, :timeout)

    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  # We already got the result before getting called, immediately respond and shutdown
  def handle_call(:register, {:done, data} = state) do
    {:stop, :normal, data, state}
  end

  # Register calling process to respond later
  def handle_call(:register, from, {type, fun, nil}) do
    {:noreply, [], {type, fun, from}}
  end

  def handle_events(events, _from, {type, fun, pid} = state) do
    {_type, val, _shard_id} =
      Enum.find(events, {nil, nil, nil}, fn
        {^type, data, _shard_id} -> fun.(data)
        _ -> false
      end)

    cond do
      # Found value and process registered, respond and shutdown
      val && pid ->
        GenServer.reply(pid, val)

        {:stop, :normal, state}

      # Found value, process did not register yet, save value
      val ->
        {:noreply, [], {:done, val}}

      true ->
        {:noreply, [], state}
    end
  end

  def handle_events(_events, _From, {:done, _} = state), do: {:noreply, [], state}
end
