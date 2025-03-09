defmodule LiveTable.Join do
  @moduledoc false

  import Ecto.Query

  # Adds LEFT JOINs to the query for any fields that reference associations
  # Fields are expected to be a map where values can include:
  # - %{assoc: {assoc_name, field_name}} for associated fields
  # - %{computed: dynamic_expr} for computed fields
  def join_associations(query, fields) do
    associations =
      fields
      |> Enum.map(fn
        {_name, %{assoc: {assoc_name, _}}} -> {:assoc, assoc_name}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    Enum.reduce(associations, query, fn
      {_association_type, assoc_name}, query ->
        join(query, :left, [resource: r], s in assoc(r, ^assoc_name), as: ^assoc_name)
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

        {name, %{assoc: {assoc_name, field_name}}} ->
          [{name, dynamic([{^assoc_name, a}], field(a, ^field_name))}]

        {name, _opts} ->
          [{name, dynamic([resource: r], field(r, ^name))}]
      end)
      |> Enum.into(%{})

    select(query, ^select_struct)
  end
end
