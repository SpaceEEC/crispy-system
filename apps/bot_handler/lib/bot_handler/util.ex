defmodule Bot.Handler.Util do
  @gateway :"gateway@127.0.0.1"
  @rest :"rest@127.0.0.1"
  @cache :"cache@127.0.0.1"

  @spec gateway(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def gateway(mod, fun, args \\ []), do: :rpc.call(@gateway, mod, fun, args) |> handle_rpc(args)

  @spec rest(fun :: atom()) :: term() | no_return()
  def rest(fun) when is_atom(fun), do: rest(fun, [])
  @spec rest(fun :: atom(), args :: list()) :: term() | no_return()
  def rest(fun, args) when is_atom(fun) and is_list(args), do: rest(Crux.Rest, fun, args)
  @spec rest(mod :: atom(), fun :: atom()) :: term() | no_return()
  def rest(mod, fun) when is_atom(mod) and is_atom(fun), do: rest(mod, fun, [])

  @spec rest(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def rest(mod, fun, args) when is_atom(mod) and is_atom(fun) and is_list(args) do
    :rpc.call(@rest, mod, fun, args)
    |> handle_rpc(args)
  end

  # @spec cache(fun :: atom()) :: term() | no_return()
  # def cache(fun) when is_atom(fun), do: cache(fun, [])
  # @spec cache(fun :: atom(), args :: list()) :: term() | no_return()
  # def cache(fun, args) when is_atom(fun) and is_list(args), do: cache(Crux.Cache, fun, args)
  # @spec cache(mod :: atom(), fun :: atom()) :: term() | no_return()
  # def cache(mod, fun) when is_atom(mod) and is_atom(fun), do: cache(mod, fun, [])

  # @spec cache(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  # def cache(mod, fun, args) when is_atom(mod) and is_atom(fun) and is_list(args) do
  #   :rpc.call(@cache, mod, fun, args)
  #   |> handle_rpc(args)
  # end

  @spec cache(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def cache(mod, fun, args \\ []) do
    mod = Module.concat(Crux.Cache, mod)

    :rpc.call(@cache, mod, fun, args)
    |> handle_rpc(args)
  end

  @spec _cache_alive?() :: boolean()
  def _cache_alive?(), do: Node.ping(@cache) == :pong

  @spec _producers() :: %{required(non_neg_integer()) => pid()} | no_return()
  def _producers(), do: :rpc.call(@cache, Bot.Cache.Application, :producers, []) |> handle_rpc([])

  defp handle_rpc({:badrpc, {:EXIT, {kind, stacktrace}}}, args) do
    # Generates an actually really good stacktraces to see what went wrong.
    exception = Exception.normalize(:error, kind, stacktrace)

    reraise Bot.Handler.RpcError, [exception, args], stacktrace
  end

  defp handle_rpc({:badrpc, reason}, args) do
    raise """
      received a non ":EXIT" ":badrcp":
      #{inspect(reason)}

      args:
      #{inspect(args)}
    """
  end

  defp handle_rpc(other, _args), do: other
end
