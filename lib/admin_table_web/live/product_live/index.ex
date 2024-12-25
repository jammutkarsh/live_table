defmodule AdminTableWeb.ProductLive.Index do
  use AdminTableWeb, :live_view

  use AdminTableWeb.LiveResource,
    schema: AdminTable.Catalog.Product

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, fields: fields())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    options = %{
      "sort" => %{
        "sortable?" => true,
        "sort_params" => [
          %{
            "sort_by" => params["sort_by"] || "id",
            "sort_order" => params["sort_order"] || "asc"
          },
          %{"sort_by" => "category_description", "sort_order" => "desc"}
        ]
      },
      "pagination" => %{
        "paginate?" => true,
        "page" => params["page"] || "1",
        "per_page" => params["per_page"] || "5"
      }
    }

    options |> dbg

    socket =
      socket
      |> stream(:resources, list_resources(fields(), options), reset: true)
      |> assign(:options, options)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", params, socket) do
    options =
      socket.assigns.options
      |> Enum.reduce(%{}, fn
        {_, v}, acc when is_map(v) ->
          Map.merge(acc, v)
      end)
      |> Map.merge(params)
      |> Map.reject(fn
        {k, v} ->
          v == "" || k not in ~w(sort_by sort_order page per_page)
      end)
      |> dbg()

    socket =
      socket
      |> push_patch(to: ~p"/products?#{options}")

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
  end

  def fields do
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

  def sort_link(%{sortable: true} = assigns) do
    ~H"""
    <.link
      phx-click="sort"
      phx-value-sort_by={@key}
      phx-value-sort_order={next_sort_order(@sort_order)}
    >
      {@label}
      <.icon
        :if={@sort_by == @key |> to_string()}
        name={
          if @sort_order == "asc",
            do: "hero-arrow-up-solid",
            else: "hero-arrow-down-solid"
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

  defp next_sort_order("asc"), do: "desc"
  defp next_sort_order("desc"), do: "asc"
end
