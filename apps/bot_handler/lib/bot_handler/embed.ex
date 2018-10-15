defmodule Bot.Handler.Embed do
  def chunk(title, text), do: chunk([], title, text) |> Enum.reverse()

  def chunk(fields, _title, nil), do: fields

  def chunk(fields, title, text) do
    [[first | _] | rest] = Regex.scan(~r/(.|[\r\n]){1,1024}/, text)

    fields = [%{name: title, value: first} | fields]

    rest =
      Enum.reduce(
        rest,
        fields,
        &[%{name: "\u200b", value: List.first(&1)} | &2]
      )
  end

  # TODO: place this somewhere better
  def html_entity_to_utf8(str) do
    Regex.replace(
      ~r{&#(.+?);},
      str,
      fn _, m ->
        <<m |> String.to_integer()::utf8>>
      end
    )
  end
end
