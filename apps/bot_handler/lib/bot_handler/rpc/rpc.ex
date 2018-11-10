defmodule Bot.Handler.Rpc do
  @moduledoc """
    Wrapper for erlang's :rpc module making calls to other node and raising proper errors on failure.
  """

  alias Bot.Handler.RpcError

  @gateway :"gateway@127.0.0.1"
  def gateway(), do: @gateway
  @rest :"rest@127.0.0.1"
  def rest(), do: @rest
  @cache :"cache@127.0.0.1"
  def cache(), do: @cache
  @lavalink :"lavalink@127.0.0.1"
  def lavalink(), do: @lavalink

  @spec gateway(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def gateway(mod, fun, args \\ []),
    do: @gateway |> :rpc.call(mod, fun, args) |> handle_rpc(args, @gateway)

  @spec rest(fun :: atom()) :: term() | no_return()
  def rest(fun) when is_atom(fun), do: rest(fun, [])
  @spec rest(fun :: atom(), args :: list()) :: term() | no_return()
  def rest(fun, args) when is_atom(fun) and is_list(args), do: rest(Crux.Rest, fun, args)
  @spec rest(mod :: atom(), fun :: atom()) :: term() | no_return()
  def rest(mod, fun) when is_atom(mod) and is_atom(fun), do: rest(mod, fun, [])

  @spec rest(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def rest(mod, fun, args) when is_atom(mod) and is_atom(fun) and is_list(args) do
    @rest
    |> :rpc.call(mod, fun, args)
    |> handle_rpc(args, @rest)
  end

  @spec lavalink(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def lavalink(mod, fun, args \\ []),
    do:
      @lavalink
      |> :rpc.call(Module.concat(Bot.Lavalink, mod), fun, args)
      |> handle_rpc(args, @lavalink)

  @spec cache(mod :: atom(), fun :: atom(), args :: list()) :: term() | no_return()
  def cache(mod, fun, args \\ []) do
    mod = Module.concat(Crux.Cache, mod)

    @cache
    |> :rpc.call(mod, fun, args)
    |> handle_rpc(args, @cache)
  end

  @spec _producers() :: %{required(non_neg_integer()) => pid()} | no_return()
  def _producers(),
    do: @cache |> :rpc.call(Bot.Cache.Application, :producers, []) |> handle_rpc([], @cache)

  def handle_rpc({:badrpc, {:EXIT, {kind, stacktrace}}}, args, _target) do
    # Generates an actually really good stacktrace to see what went wrong.
    exception = Exception.normalize(:error, kind, stacktrace)

    reraise RpcError, [exception, args], stacktrace
  end

  def handle_rpc({:badrpc, :nodedown}, args, target) do
    raise RpcError, ["The target node \"#{target}\" is down", args]
  end

  def handle_rpc({:badrpc, reason}, args, target) do
    raise RpcError, [
      """
      received an unexpected ":badrcp"
      #{inspect(reason)}

      target:
      #{target}

      """,
      args
    ]
  end

  def handle_rpc(other, _args, _target), do: other
end
