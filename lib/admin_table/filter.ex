defmodule AdminTable.Filter do
  import Ecto.Query

  def apply_text_search(query, "", _) do
    query
  end

  def apply_text_search(query, search_term, fields) do
    searchable_fields = get_searchable_fields(fields)

    conditions =
      Enum.reduce(searchable_fields, nil, fn
        field, nil when is_atom(field) ->
          dynamic([q], ilike(field(q, ^field), ^"%#{search_term}%"))

        field, acc when is_atom(field) ->
          dynamic([q], ^acc or ilike(field(q, ^field), ^"%#{search_term}%"))

        {table_name, field}, nil ->
          # {s, _} = get_table_name(table_name)
          dynamic([{^table_name, s}], ilike(field(s, ^field), ^"%#{search_term}%"))

        {table_name, field}, acc ->
          # {s, _} = get_table_name(table_name)
          dynamic([{^table_name, s}], ^acc or ilike(field(s, ^field), ^"%#{search_term}%"))
      end)

    where(query, ^conditions)
  end

  defp get_searchable_fields(fields) do
    fields
    |> Enum.flat_map(fn
      {_key, %{assoc: {assoc, field}, searchable: true}} ->
        [{assoc, field}]

      {field, %{searchable: true}} ->
        [field]

      _ ->
        []
    end)
  end

  defp apply_custom_filters(query, nil, _filters), do: query

  defp apply_custom_filters(query, filter_values, filters) do
    filter_values |> dbg()
    filters |> dbg()

    Enum.reduce(filters, query, fn {filter_key, filter}, acc ->
      value =
        get_in(filter_values, [to_string(filter_key)])

      filter.__struct__.apply(acc, %{
        field: filter.field,
        options: Map.get(filter, :options),
        value: value
      })
    end)
  end
end
