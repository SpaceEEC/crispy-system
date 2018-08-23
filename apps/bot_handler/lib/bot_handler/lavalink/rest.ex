defmodule Bot.Handler.Lavalink.Rest do
  @url "localhost:2333/loadtracks"
  @authorization "12345"

  @spec resolve_identifier(url :: String.t()) :: {String.t(), boolean()}
  def resolve_identifier(url) do
    cond do
      Regex.match?(~r{^(?:https?://)?(?:www\.)?youtube\.com/watch\?v=.+}, url) or
        Regex.match?(~r{^(?:https?://)?(?:www\.)?soundcloud.com/.+}, url) or
        Regex.match?(~r{^(?:https?://)?(?:www\.)?twitch\.tv/.+}, url) or
          Regex.match?(~r{^(?:https?://)?(?:www\.)?youtu\.be/.+}, url) ->
        {url, false}

      Regex.match?(~r{^(?:https?://)?(?:www\.)?youtube\.com/playlist\?list=.+}, url) ->
        {url, true}

      true ->
        {"ytsearch:#{url}", false}
    end
  end

  @spec fetch_tracks(identifier :: String.t()) :: {:ok, list()} | {:error, term()}
  def fetch_tracks(identifier) do
    res =
      HTTPoison.get(
        @url,
        [{"Authorization", @authorization}],
        params: [identifier: identifier]
      )

    with {:ok, %{body: body}} <- res,
         {:ok, %{tracks: tracks}} <- Poison.decode(body, keys: :atoms) do
      {:ok, tracks}
    else
      {:error, _error} = tuple ->
        tuple

      error ->
        {:error, error}
    end
  end
end
