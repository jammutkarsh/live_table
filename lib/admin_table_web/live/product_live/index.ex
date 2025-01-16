defmodule AdminTableWeb.ProductLive.Index do
  use AdminTableWeb, :live_view
  alias AdminTable.Boolean

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
      |> Map.merge(%{"search" => params["search"] || ""})
      |> Enum.reduce(%{}, fn
        {"search", search_term}, acc -> Map.put(acc, "search", search_term)
        {k, v}, acc -> Map.put(acc, k, filters()[k |> String.to_atom()])
      end)

    # Update Workflow

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
        {_, v}, acc when is_map(v) ->
          Map.merge(acc, v)
      end)
      |> Map.merge(params)
      |> update_sort_params(sort_params, shift_key)
      |> update_filter_params(filter_params)
      |> Map.take(~w(page per_page search sort_params filters))
      |> Map.reject(fn {_, v} -> v == "" || is_nil(v) end)
      # |> dbg()

    # Update Workflow

    socket =
      socket
      |> push_patch(to: ~p"/products?#{options}")

    {:noreply, socket}
  end

  defp update_filter_params(map, nil), do: map

  defp update_filter_params(map, params) do
    cond = params |> Enum.reduce(%{}, fn
      {k, "true"}, acc ->
    %{field: field, key: key} = get_filter(k)
    Map.put(acc, k, key)
    _, acc -> acc
      end)
    Map.replace(map, "filters", cond)
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
          %{label: "Email", condition: dynamic([p, s], s.contact_info == "procurement@autopartsdirect.com")}
        )
    ]
  end

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

  defp get_filter(key) do
    key = key |> String.to_existing_atom()
    filters() |> Keyword.get(key)
  end

  defp next_sort_order("asc"), do: "desc"
  defp next_sort_order("desc"), do: "asc"
  defp next_sort_order(_), do: raise(ArgumentError)
end
