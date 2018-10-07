defmodule Bot.Handler.Etcd do
  @moduledoc false

  alias Bot.Handler.Rest

  @address "http://localhost:2379/v3beta/kv/"

  @spec get!(key :: String.t(), default :: String.t() | nil) :: String.t() | nil | no_return()
  def get!(key, default \\ nil) do
    case get(key, default) do
      {:ok, res} ->
        res

      {:error, error} ->
        raise error
    end
  end

  @spec get(
          key :: String.t(),
          default :: String.t() | nil
        ) :: {:ok, String.t() | nil} | {:error, term()}
  def get(key, default \\ nil) do
    with {:ok, %{body: body}} <- Rest.post(@address <> "range", %{key: Base.encode64(key)}) do
      case body do
        %{"kvs" => [%{"value" => value}]} ->
          Base.decode64(value)

        _ ->
          {:ok, default}
      end
    end
  end

  @spec put!(key :: String.t(), value :: String.t()) :: :ok | no_return()
  def put!(key, value) do
    with {:error, error} <- put(key, value) do
      raise error
    end
  end

  @spec put(key :: String.t(), value :: String.t()) :: :ok | {:error, term()}
  def put(key, value) do
    with {:ok, _} <-
           Rest.post(@address <> "put", %{
             key: Base.encode64(key),
             value: Base.encode64(value)
           }) do
      :ok
    end
  end

  @spec delete!(key :: String.t()) :: non_neg_integer() | no_return()
  def delete!(key) do
    case delete(key) do
      {:ok, deleted} ->
        deleted

      {:error, error} ->
        raise error
    end
  end

  @spec delete(key :: String.t()) :: {:ok, non_neg_integer()} | {:error, term()}
  def delete(key) do
    with {:ok, %{body: %{"deleted" => deleted}}} <-
           Rest.post(@address <> "deleterange", %{key: Base.encode64(key)}) do
      {:ok, deleted}
    end
  end
end
