defmodule Bot.Handler.Config do
  @callback transform_base(base :: term()) :: String.t()
  @callback run(
              fun :: atom(),
              base :: term(),
              key :: String.t(),
              value :: term()
            ) :: :ok | term() | no_return() | {:ok, term()} | {:error, term()}

  @optional_callbacks transform_base: 1, run: 4
end
