defmodule Bot.Handler.Config do
  @moduledoc false

  @callback put!(
              base :: term(),
              key :: String.t(),
              value :: String.t()
            ) :: :ok | no_return()

  @callback put(
              base :: term(),
              key :: String.t(),
              value :: String.t()
            ) :: :ok | {:error, term()}

  @callback get!(
              base :: term(),
              key :: String.t(),
              default_value :: term()
            ) :: term() | no_return()
  @callback get(
              base :: term(),
              key :: String.t(),
              default_value :: term()
            ) :: {:ok, term()} | {:error, term()}

  @callback delete!(
              base :: term(),
              key :: String.t()
            ) :: non_neg_integer() | no_return()

  @callback delete(
              base :: term(),
              key :: String.t()
            ) :: {:ok, non_neg_integer()} | {:error, term()}
end
