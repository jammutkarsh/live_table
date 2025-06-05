defmodule LiveTable.Join do
  @moduledoc false

  import Ecto.Query

  # Adds LEFT JOINs to the query for any fields that reference associations
  # Fields are expected to be a map where values can include:
  # - %{assoc: {assoc_name, field_name}} for associated fields
  # - %{computed: dynamic_expr} for computed fields
  def join_associations(query, filters) do
    filter_assocs = get_filter_assocs(filters)

    filter_assocs
    |> Enum.uniq()
    |> Enum.reduce(query, fn
      assoc_name, query ->
        if has_named_binding?(query, assoc_name) do
          query
        else
          join(query, :left, [r], s in assoc(r, ^assoc_name), as: ^assoc_name)
        end
    end)
  end

  # Builds a select statement that includes:
  # - Regular fields from the main table
  # - Fields from associated tables
  # - Computed fields using dynamic expressions
  def select_columns(query, fields) do
    select_struct =
      Enum.flat_map(fields, fn
        {name, %{computed: dynamic_expr}} ->
          [{name, dynamic_expr}]

        {name, _opts} ->
          [{name, dynamic([resource: r], field(r, ^name))}]
      end)
      |> Enum.into(%{})

    select(query, ^select_struct)
  end

  defp get_filter_assocs(filters) do
    filters
    |> Enum.map(fn
      {_name, %{field: {assoc_name, _}}} -> assoc_name
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end
end
