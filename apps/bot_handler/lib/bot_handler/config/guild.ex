defmodule Bot.Handler.Config.Guild do
  alias Crux.Structs.Guild
  use Bot.Handler.Config.Base

  def transform_base(%Guild{id: guild_id}), do: guild_id |> to_string()
  def transform_base(guild_id) when is_integer(guild_id), do: guild_id |> to_string()
  def transform_base(guild_id) when is_binary(guild_id), do: guild_id
end
