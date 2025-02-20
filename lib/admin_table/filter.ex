defmodule AdminTable.Filter do
  import Ecto.Query

  def apply_text_search("", _) do
    true
  end

  def apply_text_search(search_term, fields) do
    searchable_fields = get_searchable_fields(fields)

    Enum.reduce(searchable_fields, nil, fn
      field, nil when is_atom(field) ->
        dynamic([p], ilike(field(p, ^field), ^"%#{search_term}%"))

      field, acc when is_atom(field) ->
        dynamic([p], ^acc or ilike(field(p, ^field), ^"%#{search_term}%"))

      {table_name, field}, nil ->
        dynamic([{^table_name, p}], ilike(field(p, ^field), ^"%#{search_term}%"))

      {table_name, field}, acc ->
        dynamic([{^table_name, p}], ^acc or ilike(field(p, ^field), ^"%#{search_term}%"))
    end)
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

  def apply_filters(query, %{"search" => ""} = filters, _) when map_size(filters) == 1, do: query

  def apply_filters(query, filters, fields) do
        conditions =
      filters
      |> Enum.reduce(true, fn
        {"search", search_term}, acc ->
          text_search_condition = apply_text_search(search_term, fields)
          dynamic(^acc and ^text_search_condition)

        {_filter_key, filter}, acc ->
          filter.__struct__.apply(acc, filter)
      end)

    where(query, ^conditions)
  end
end
