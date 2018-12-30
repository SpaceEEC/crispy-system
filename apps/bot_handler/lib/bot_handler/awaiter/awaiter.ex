defmodule Bot.Handler.Awaiter do
  use GenStage

  alias Crux.Base.Consumer

  alias Bot.Handler.Rpc
  alias __MODULE__

  @type events :: atom() | list(atom())
  @type fun :: (Consumer.event() -> boolean())
  @type fun_reduce_while :: (Consumer.event(), term() -> {:cont, term()} | {:halt, term()})

  @spec await(
          events :: events(),
          fun :: fun(),
          timeout :: timeout()
        ) :: Consumer.event() | :timeout
  def await(events, fun, timeout \\ 5000) do
    fun = fn packet, nil ->
      if fun.(packet) do
        {:halt, packet}
      else
        {:cont, nil}
      end
    end

    start(events, nil, timeout, fun)
  end

  @spec await_while(
          events :: events(),
          fun :: fun(),
          timeout :: timeout()
        ) :: list(Consumer.event()) | :timeout
  def await_while(events, fun, timeout \\ 5000) do
    fun = fn packet, acc ->
      if fun.(packet) do
        {:cont, [packet | acc]}
      else
        {:halt, Enum.reverse(acc)}
      end
    end

    start(events, [], timeout, fun)
  end

  @spec await_reduce(
          events :: events(),
          fun :: fun_reduce_while(),
          initial_state :: term(),
          timeout :: timeout()
        ) :: term() | :timeout
  def await_reduce(events, fun, initial_state \\ nil, timeout \\ 5000) do
    start(events, initial_state, timeout, fun)
  end

  defp start(events, state, timeout, fun) do
    args = %{
      events: events |> List.wrap(),
      state: state,
      timeout: timeout,
      fun: fun,
      producer: Rpc._producers() |> Map.values()
    }

    {:ok, pid} = Awaiter.Supervisor.start_child(args)

    try do
      GenStage.call(pid, :register, timeout)
    catch
      :exit, value ->
        value
    end
  end

  defstruct(
    events: MapSet.new(),
    state: nil,
    fun: nil,
    pid: nil
  )

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  def init(%{
        events: events,
        state: state,
        timeout: timeout,
        fun: fun,
        producer: producer
      }) do
    state = %__MODULE__{
      events: events |> MapSet.new(),
      state: state,
      fun: fun,
      pid: nil
    }

    unless timeout == :infinity do
      :timer.send_after(timeout, :timeout)
    end

    {:consumer, state, subscribe_to: producer}
  end

  def handle_call(:register, from, state) do
    {:noreply, [], Map.put(state, :pid, from)}
  end

  def handle_info(:timeout, %{pid: pid, cons_state: cons_state} = state) do
    GenStage.reply(pid, cons_state)

    {:stop, :normal, state}
  end

  def handle_events(
        packets,
        _from,
        %{pid: pid, events: events, state: cons_state, fun: fun} = state
      ) do
    packets
    |> Enum.filter(&MapSet.member?(events, elem(&1, 0)))
    |> Enum.reduce_while(
      cons_state,
      fn packet, state ->
        case fun.(packet, state) do
          {:cont, _state} = cont ->
            cont

          {:halt, _halt} = halt ->
            {:halt, halt}
        end
      end
    )
    |> case do
      {:halt, cons_state} ->
        GenStage.reply(pid, cons_state)

        {:stop, :normal, Map.put(state, :cons_state, cons_state)}

      cons_state ->
        {:noreply, [], Map.put(state, :cons_state, cons_state)}
    end
  end
end
