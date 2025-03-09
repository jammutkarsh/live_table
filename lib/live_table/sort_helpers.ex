defmodule LiveTable.SortHelpers do
  @moduledoc false
  use Phoenix.Component

  # Renders a sortable column header with sort direction indicator
  def sort_link(%{sortable: true} = assigns) do
    components_module = Application.get_env(:live_table, :components, LiveTable.Components)
    assigns = Map.put(assigns, :components_module, components_module)

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
      <.dynamic_component
        :if={Keyword.has_key?(@sort_params, @key)}
        module={@components_module}
        function={:icon}
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

  
  # Renders a non-sortable column header
  def sort_link(assigns) do
    ~H"""
    {@label}
    """
  end

  # Toggles sort order between ascending and descending
  def next_sort_order("asc"), do: "desc"
  def next_sort_order("desc"), do: "asc"

  # Updates sort parameters in the state map when params are nil
  def update_sort_params(map, nil, _), do: map

  # Merges new sort params with existing ones when shift key is pressed
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

  # Replaces existing sort params with new ones when shift key is not pressed
  def update_sort_params(map, params, false) do
    p =
      params
      |> Jason.decode!()
      |> Keyword.new(fn {k, v} -> {String.to_existing_atom(k), String.to_existing_atom(v)} end)

    map
    |> Map.put("sort_params", p)
  end

  # Merges two keyword lists while preserving unique keys
  def merge_lists(list1, list2) do
    list2_map = Enum.into(list2, %{})

    list1
    |> Enum.map(fn {key, value} ->
      {key, Map.get(list2_map, key, value)}
    end)
    |> Kernel.++(Enum.reject(list2, fn {key, _} -> key in Keyword.keys(list1) end))
  end

  # Dynamically calls a component function from a specified module. Used if user specifies a custom module.
  def dynamic_component(assigns) do
    {module, assigns} = Map.pop(assigns, :module)
    {function, assigns} = Map.pop(assigns, :function)
    apply(module, function, [assigns])
  end
end
