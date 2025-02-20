defmodule AdminTable.SortHelpers do
  use Phoenix.Component

  def sort_link(%{sortable: true} = assigns) do
    ~H"""
    <.link
      id={@key}
      phx-click="sort"
      phx-value-sort={
        Jason.encode!(%{
          @key => (@sort_params[@key] || :asc) |> to_string() |> next_sort_order()
        })
      }
      phx-hook="SortableColumn"
    >
      {@label}
      <AdminTableWeb.CoreComponents.icon
        :if={Keyword.has_key?(@sort_params, @key)}
        name={
          if Keyword.get(@sort_params, @key) == :asc do
            "hero-arrow-up-solid"
          else
            "hero-arrow-down-solid"
          end
        }
        class="w-4 h-4 text-gray-900"
      />
    </.link>
    """
  end

  def sort_link(assigns) do
    ~H"""
    {@label}
    """
  end

  def next_sort_order("asc"), do: "desc"
  def next_sort_order("desc"), do: "asc"

  def update_sort_params(map, nil, _), do: map

  def update_sort_params(map, params, true) do
    p =
      params
      |> Jason.decode!()
      |> Keyword.new(fn {k, v} -> {String.to_existing_atom(k), String.to_existing_atom(v)} end)

    map
    |> Map.update("sort_params", nil, fn x ->
      merge_lists(x, p)
    end)
  end

  def update_sort_params(map, params, false) do
    p =
      params
      |> Jason.decode!()
      |> Keyword.new(fn {k, v} -> {String.to_existing_atom(k), String.to_existing_atom(v)} end)

    map
    |> Map.put("sort_params", p)
  end

  def merge_lists(list1, list2) do
    list2_map = Enum.into(list2, %{})

    list1
    |> Enum.map(fn {key, value} ->
      {key, Map.get(list2_map, key, value)}
    end)
    |> Kernel.++(Enum.reject(list2, fn {key, _} -> key in Keyword.keys(list1) end))
  end
end
