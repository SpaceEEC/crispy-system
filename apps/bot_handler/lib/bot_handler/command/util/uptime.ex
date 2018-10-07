defmodule Bot.Handler.Command.Util.Uptime do
  @moduledoc false

  @behaviour Bot.Handler.Command

  def description(), do: "Gets the uptime of the nodes."

  def process(_message, _args) do
    data =
      [Node.self() | Node.list()]
      |> fetch_nodes_data()

    longest =
      data
      |> Map.keys()
      |> Enum.max_by(fn node -> String.length(node) end)
      |> String.length()

    content =
      Enum.map_join(data, "\n", fn {node, uptime} ->
        "#{String.pad_trailing(node, longest)} :: #{uptime}"
      end)

    content = """
    **Uptime:**
    ```asciidoc
    #{content}
    ```
    """

    {:respond, content}
  end

  defp fetch_nodes_data(nodes) do
    nodes
    |> Map.new(fn node ->
      uptime =
        node
        |> fetch_uptime()
        |> format_uptime()

      node = format_node_name(node)

      {node, uptime}
    end)
  end

  defp fetch_uptime(node) do
    node
    |> :rpc.call(:erlang, :statistics, [:wall_clock])
    |> elem(0)
  end

  defp format_uptime(uptime) do
    uptime = div(uptime, 1000)

    seconds =
      uptime
      |> rem(60)
      |> to_string
      |> String.pad_leading(2, "0")

    uptime = div(uptime, 60)

    minutes =
      uptime
      |> rem(60)
      |> to_string
      |> String.pad_leading(2, "0")

    uptime = div(uptime, 60)

    hours =
      uptime
      |> rem(24)
      |> to_string
      |> String.pad_leading(2, "0")

    days = div(uptime, 24)

    uptime =
      if days == 0 do
        ""
      else
        "#{days} days "
      end

    "#{uptime}#{hours}:#{minutes}:#{seconds}"
  end

  defp format_node_name(node) do
    node
    |> to_string()
    |> String.split("@")
    |> List.first()
    |> String.capitalize()
  end
end
