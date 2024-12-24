defmodule AdminTable.Sorting do
  import Ecto.Query

  def maybe_sort(query, _, false), do: query

  def maybe_sort(query, sort_params, true) do
    query |> sort([sort_params])
  end

  def sort(query, sort_params) do
    sorts =
      sort_params |> dbg()
      |> Enum.map(fn
        %{"sort_by" => sort_by, "sort_order" => "asc"} ->
          sort_by = sort_by |> String.to_existing_atom() 
          sort_by|> dbg()
          {:asc, sort_by}

        %{"sort_by" => sort_by, "sort_order" => "desc"} ->
          sort_by = sort_by |> String.to_existing_atom()
          {:desc, sort_by}

        _ ->
          {:asc, :inserted_at}
      end)

    from q in query, order_by: ^sorts
  end
end
