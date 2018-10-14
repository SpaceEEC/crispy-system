defmodule Bot.Handler.RpcError do
  @moduledoc """
    Wrapper around rpc errors.

    Produces a proper message including the caller's args.
  """
  defexception [:original, :args, :message]

  def exception(message) when is_bitstring(message) do
    %__MODULE__{message: message}
  end

  def exception([original]), do: exception([original, []])

  def exception([original, args]) when is_map(original) do
    %__MODULE__{original: original, args: args}
  end

  def exception([message, args]) do
    %__MODULE__{message: message, args: args}
  end

  def message(%__MODULE__{message: nil, original: original, args: args}) do
    "args: #{inspect(args)}\n** (#{inspect(original.__struct__)}) #{Exception.message(original)}"
  end

  def message(%__MODULE__{message: message, original: nil, args: args}) do
    "#{message}\nargs: #{inspect(args)}"
  end

  def message(%__MODULE__{message: message}) do
    message
  end
end
