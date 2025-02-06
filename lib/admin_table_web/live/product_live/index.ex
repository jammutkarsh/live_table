defmodule AdminTableWeb.ProductLive.Index do
  use AdminTableWeb, :live_view
  alias AdminTable.{Boolean, Range, Select, Catalog}
  import LiveSelect

  use AdminTableWeb.LiveResource,
    schema: AdminTable.Catalog.Product

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, fields: fields(), options: %{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    sort_params =
      Map.get(params, "sort_params", %{"id" => "asc"})
      |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_atom(v)} end)

    filters =
      Map.get(params, "filters", %{})
      |> Map.put("search", params["search"] || "")
      |> Enum.reduce(%{}, fn
        {"search", search_term}, acc ->
          Map.put(acc, "search", search_term)

        {key, %{"min" => min, "max" => max}}, acc ->
          filter = get_filter(key)
          {min_val, max_val} = parse_range_values(filter.options.type, min, max)
          filter = %{filter | options: %{filter.options | min: min_val, max: max_val}}
          key = key |> String.to_atom()
          Map.put(acc, key, filter)

        {key, %{"id" => id}}, acc ->
          filter = %AdminTable.Select{} = get_filter(key)
          id = id |> Enum.map(&String.to_integer/1)
          filter = %{filter | options: Map.update!(filter.options, :selected, &(&1 ++ id))}
          key = key |> String.to_existing_atom()
          Map.put(acc, key, filter)
        {k, _}, acc ->
          key = k |> String.to_existing_atom()
          Map.put(acc, key, get_filter(k))
      end)

    options = %{
      "sort" => %{
        "sortable?" => true,
        "sort_params" => sort_params
      },
      "pagination" => %{
        "paginate?" => true,
        "page" => params["page"] || "1",
        "per_page" => params["per_page"] || "5"
      },
      "filters" => filters
    }

    socket =
      socket
      |> stream(:resources, list_resources(fields(), options), reset: true)
      |> assign(:options, options)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", params, socket) do
    # params |> dbg()

    shift_key = Map.get(params, "shift_key", false)
    sort_params = Map.get(params, "sort", nil)
    filter_params = Map.get(params, "filters", nil)

    options =
      socket.assigns.options
      |> Enum.reduce(%{}, fn
        {"filters", %{"search" => search_term} = v}, acc ->
          filters = encode_filters(v)
          Map.put(acc, "filters", filters) |> Map.put("search", search_term)

        {_, v}, acc when is_map(v) ->
          Map.merge(acc, v)
      end)
      |> Map.merge(params, fn
        "filters", v1, v2 when is_map(v1) and is_map(v2) -> v1
        _, _, v -> v
      end)
      |> update_sort_params(sort_params, shift_key)
      |> update_filter_params(filter_params)
      |> Map.take(~w(page per_page search sort_params filters))
      |> Map.reject(fn {_, v} -> v == "" || is_nil(v) end)

    socket =
      socket
      |> push_patch(to: ~p"/products?#{options}")

    {:noreply, socket}
  end

  def handle_event("live_select_change", %{"text" => text, "id" => id}, socket) do
    options = case get_filter(id) do
    %AdminTable.Select{options: %{options: _options, options_source: {module, function, args}}} -> apply(module, function, [text | args])
     %AdminTable.Select{options: %{options: options, options_source: nil}} -> options
    end
    send_update(LiveSelect.Component, id: id, options: options)

    {:noreply, socket}
  end

  def encode_filters(filters) do
    Enum.reduce(filters, %{}, fn
      {k, %AdminTable.Range{options: %{min: min, max: max, type: :number}}}, acc ->
        k = k |> to_string
        acc |> Map.merge(%{k => [min: min, max: max]})

      {k, %AdminTable.Range{options: %{min: min, max: max, type: :date}}}, acc ->
        k = k |> to_string
        min = min |> Date.to_iso8601()
        max = max |> Date.to_iso8601()
        acc |> Map.merge(%{k => [min: min, max: max]})

      {k, %AdminTable.Range{options: %{min: min, max: max, type: :datetime}}}, acc ->
        k = k |> to_string
        min = min |> NaiveDateTime.to_iso8601()
        max = max |> NaiveDateTime.to_iso8601()
        acc |> Map.merge(%{k => [min: min, max: max]})

      {k, %AdminTable.Boolean{field: _, key: key}}, acc ->
        k = k |> to_string
        acc |> Map.merge(%{k => key})

      {k, %AdminTable.Select{options: %{selected: selected}}}, acc ->
        k = k |> to_string
        acc |> Map.merge(%{k => %{id: selected}})

      _, acc ->
        acc
    end)
  end

  defp update_filter_params(map, nil), do: map

  defp update_filter_params(map, params) do
    existing_filters = Map.get(map, "filters", %{})

    updated_params =
      params
      |> Enum.reduce(existing_filters, fn
        {k, "true"}, acc ->
          %{field: _, key: key} = get_filter(k)
          Map.put(acc, k, key)

        {key, %{"max" => max, "min" => min}}, acc ->
          Map.put(acc, key, min: min, max: max)

        {k, "false"}, acc ->
          Map.delete(acc, k)

        {key, "[" <> rest}, acc ->
          case get_filter(key) do
            %AdminTable.Select{} ->
              id = ("[" <> rest) |> Jason.decode!() |> List.first()
              Map.put(acc, key, %{id: [id]})

            true ->
              acc
          end

        _, acc ->
          acc
      end)

    Map.put(map, "filters", updated_params)
  end

  defp update_sort_params(map, nil, _), do: map

  defp update_sort_params(map, params, true) do
    p =
      params
      |> Jason.decode!()
      |> Keyword.new(fn {k, v} -> {String.to_existing_atom(k), String.to_existing_atom(v)} end)

    map
    |> Map.update("sort_params", nil, fn x ->
      merge_lists(x, p)
    end)
  end

  defp update_sort_params(map, params, false) do
    p =
      params
      |> Jason.decode!()
      |> Keyword.new(fn {k, v} -> {String.to_existing_atom(k), String.to_existing_atom(v)} end)

    map
    |> Map.put("sort_params", p)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
  end

  defp merge_lists(list1, list2) do
    list2_map = Enum.into(list2, %{})

    list1
    |> Enum.map(fn {key, value} ->
      {key, Map.get(list2_map, key, value)}
    end)
    |> Kernel.++(Enum.reject(list2, fn {key, _} -> key in Keyword.keys(list1) end))
  end

  def fields() do
    [
      id: %{
        label: "ID",
        sortable: true,
        searchable: false
      },
      name: %{
        label: "Product Name",
        sortable: true,
        searchable: true
      },
      description: %{
        label: "Description",
        sortable: true,
        searchable: true
      },
      price: %{
        label: "Price",
        sortable: true,
        searchable: false
      },
      supplier_name: %{
        label: "Supplier Name",
        assoc: {:suppliers, :name},
        searchable: true,
        sortable: false
      },
      supplier_description: %{
        label: "Supplier Email",
        assoc: {:suppliers, :contact_info},
        searchable: true,
        sortable: true
      },
      category_name: %{
        label: "Category Name",
        assoc: {:category, :name},
        searchable: false,
        sortable: false
      },
      category_description: %{
        label: "Category Description",
        assoc: {:category, :description},
        searchable: true,
        sortable: true
      },
      image: %{
        label: "Image",
        sortable: false,
        searchable: false,
        assoc: {:image, :url}
      }
    ]
  end

  def filters() do
    [
      price:
        Boolean.new(
          :price,
          "under-100",
          %{label: "Less than 100", condition: dynamic([p], p.price < 100)}
        ),
      cost_filter:
        Boolean.new(
          :supplier_email,
          "supplier",
          %{
            label: "Email",
            condition: dynamic([p, s], s.contact_info == "procurement@autopartsdirect.com")
          }
        ),
      # prices:
      #   Range.new(:price, "10-to-100", %{label: "Enter range", min: 0, max: 500, unit: "$"}),
      supplier_name:
        Select.new({:suppliers, :name}, "suppliser_name", %{
          label: "Supplier",
          placeholder: "Search for suppliers...",
          options_source: {AdminTable.Catalog, :search_suppliers, []}
          # options: [{"Auto Parts Direct", ["id"]}],
          # option_template: &custom_template/1,
        })
    ]
  end

  # def custom_template(option) do
  #   assigns = %{option: option}
  #   ~H"""
  #   <div class="flex flex-col">
  #     <span class="font-bold"><%= @option.label %></span> inas
  #     <span class="text-sm text-gray-500"><%= @option.value |> Enum.at(0) %></span>
  #   </div>
  #   """
  # end

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
      <.icon
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

  defp get_filter(key) when is_binary(key) do
    key
    |> String.to_existing_atom()
    |> get_filter()
  end

  defp get_filter(key) when is_atom(key) do
    filters() |> Keyword.get(key)
  end

  defp next_sort_order("asc"), do: "desc"
  defp next_sort_order("desc"), do: "asc"
  defp next_sort_order(_), do: raise(ArgumentError)

  defp parse_range_values(:number, min, max) do
    {min_float, _} = Float.parse(min)
    {max_float, _} = Float.parse(max)
    {min_float, max_float}
  end

  defp parse_range_values(:date, min, max) do
    {Date.from_iso8601!(min), Date.from_iso8601!(max)}
  end

  defp parse_range_values(:datetime, min, max) do
    {NaiveDateTime.from_iso8601!(min), NaiveDateTime.from_iso8601!(max)}
  end
end
