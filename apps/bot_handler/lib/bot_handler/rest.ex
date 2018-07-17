defmodule Bot.Handler.Rest do
  use HTTPoison.Base

  @user_agent "crispy-system (https://github.com/spaceeec/crispy-system.git)"

  def process_request_headers(headers) do
    headers
    |> Keyword.put_new(:"user-agent", @user_agent)
    |> Keyword.put_new(:accept, "application/json")
    |> Keyword.put_new(:"content-type", "application/json")
  end

  def process_response_body(body) when is_bitstring(body) do
    with {:ok, res} <- Poison.decode(body) do
      res
    else
      _ -> body
    end
  end

  def process_response_body(body), do: body
end
