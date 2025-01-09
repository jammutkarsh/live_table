defmodule AdminTable.Filter do
  import Ecto.Query

  def apply_text_search("", _) do
    true
  end

  def apply_text_search(search_term, fields) do
    searchable_fields = get_searchable_fields(fields)

    Enum.reduce(searchable_fields, nil, fn
      field, nil when is_atom(field) ->
        dynamic([q], ilike(field(q, ^field), ^"%#{search_term}%"))

      field, acc when is_atom(field) ->
        dynamic([q], ^acc or ilike(field(q, ^field), ^"%#{search_term}%"))

      {table_name, field}, nil ->
        dynamic([{^table_name, s}], ilike(field(s, ^field), ^"%#{search_term}%"))

      {table_name, field}, acc ->
        dynamic([{^table_name, s}], ^acc or ilike(field(s, ^field), ^"%#{search_term}%"))
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
        f =
      filters
      |> Enum.reduce(true, fn
        {"search", search_term}, acc ->
          text_search_condition = apply_text_search(search_term, fields)
          dynamic(^acc and ^text_search_condition)

        {filter_key, filter}, acc ->
          filter.__struct__.apply(acc, %{filter_key: filter})
      end)

    where(query, ^f) |> dbg()
  end

  # defp apply_custom_filters(query, nil, _filters), do: query

  # defp apply_custom_filters(query, filter_values, filters) do

  #   Enum.reduce(filters, query, fn {filter_key, filter}, acc ->
  #     value =
  #       get_in(filter_values, [to_string(filter_key)])

  #     filter.__struct__.apply(acc, %{
  #       field: filter.field,
  #       options: Map.get(filter, :options),
  #       value: value
  #     })
  #   end)
  # end
end
