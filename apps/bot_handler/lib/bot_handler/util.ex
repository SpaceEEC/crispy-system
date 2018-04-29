defmodule Bot.Handler.Util do
  @gateway :gateway@localhost
  @rest :rest@localhost
  @cache :cache@localhost

  def gateway(mod, fun, args \\ []), do: :rpc.call(@gateway, mod, fun, args) |> handle_rpc()

  def rest(fun) when is_atom(fun), do: rest(fun, [])
  def rest(fun, args) when is_atom(fun) and is_list(args), do: rest(Crux.Rest, fun, args)
  def rest(mod, fun) when is_atom(mod) and is_atom(fun), do: rest(mod, fun, [])

  def rest(mod, fun, args) when is_atom(mod) and is_atom(fun) and is_list(args) do
    :rpc.call(@rest, mod, fun, args)
    |> handle_rpc()
  end

  def cache(mod, fun, args \\ []) do
    mod = Module.concat(Crux.Cache, mod)

    :rpc.call(@cache, mod, fun, args)
    |> handle_rpc()
  end

  def _producers(), do: :rpc.call(@cache, Bot.Cache.Application, :producers, []) |> handle_rpc()

  defp handle_rpc({:badrpc, reason}), do: raise(inspect(reason))
  defp handle_rpc(other), do: other
end
