defmodule Bot.Handler.Config.Base do
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Bot.Handler.Config

      @spec put!(
              base :: term(),
              key :: String.t(),
              value :: String.t()
            ) :: :ok | no_return()
      def put!(base, key, value) do
        run(:put!, base, key, value)
      end

      @spec put(
              base :: term(),
              key :: String.t(),
              value :: String.t()
            ) :: :ok | {:error, term()}
      def put(base, key, value) do
        run(:put, base, key, value)
      end

      @spec get!(
              base :: term(),
              key :: String.t(),
              default_value :: term()
            ) :: term() | no_return()
      def get!(base, key, default_value \\ nil) do
        run(:get!, base, key, default_value)
      end

      @spec get(
              base :: term(),
              key :: String.t(),
              default_value :: term()
            ) :: {:ok, term()} | {:error, term()}
      def get(base, key, default_value \\ nil) do
        run(:get, base, key, default_value)
      end

      @spec delete!(
              base :: term(),
              key :: String.t()
            ) :: non_neg_integer() | no_return()
      def delete!(base, key) do
        run(:delete!, base, key)
      end

      @spec delete(
              base :: term(),
              key :: String.t()
            ) :: {:ok, non_neg_integer()} | {:error, term()}
      def delete(base, key) do
        run(:delete, base, key)
      end

      def transform_base(base), do: base

      def run(fun, base, key, value \\ nil) do
        base = transform_base(base)
        alias Bot.Handler.Etcd
        Code.ensure_loaded(Etcd)

        if function_exported?(Etcd, fun, 2) do
          apply(Etcd, fun, ["#{base}#{key}", value])
        else
          apply(Etcd, fun, ["#{base}#{key}"])
        end
      end

      defoverridable transform_base: 1, run: 4
    end
  end
end
