defmodule Bot.Handler.Util do
  @gateway :"gateway@127.0.0.1"
  @rest :"rest@127.0.0.1"
  @cache :"cache@127.0.0.1"


  def gateway(mod, fun, args \\ []), do: :rpc.call(@gateway, mod, fun, args) |> handle_rpc(args)

  def rest(fun) when is_atom(fun), do: rest(fun, [])
  def rest(fun, args) when is_atom(fun) and is_list(args), do: rest(Crux.Rest, fun, args)
  def rest(mod, fun) when is_atom(mod) and is_atom(fun), do: rest(mod, fun, [])

  def rest(mod, fun, args) when is_atom(mod) and is_atom(fun) and is_list(args) do
    :rpc.call(@rest, mod, fun, args)
    |> handle_rpc(args)
  end

  def cache(mod, fun, args \\ []) do
    mod = Module.concat(Crux.Cache, mod)

    :rpc.call(@cache, mod, fun, args)
    |> handle_rpc(args)
  end

  def _cache_alive?(), do: Node.ping(@cache) == :pong
  def _producers(), do: :rpc.call(@cache, Bot.Cache.Application, :producers, []) |> handle_rpc([])

  defp handle_rpc({:badrpc, reason}, args), do: raise(inspect(args) <> inspect(reason))
  defp handle_rpc(other, _args), do: other
end
