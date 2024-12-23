defmodule AdminTableWeb.PostLive.Index do
  use AdminTableWeb, :live_view

  use TestWeb.LiveResource,
    schema: AdminTable.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, fields: fields())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    options = %{
      "sort" => %{
        "sortable?" => true,
        "sort_by" => params["sort_by"] || "id",
        "sort_order" => params["sort_order"] || "asc"
      }
    }

    socket =
      socket
      |> stream(:posts, list_resources(fields(), options), reset: true)
      |> assign(:options, options)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", params, socket) do
    socket =
      socket
      |> push_patch(to: ~p"/posts?#{params}")

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  def fields do
    [
      id: %{
        label: "ID",
        sortable: true,
        searchable: false
      },
      body: %{
        label: "Body",
        sortable: true,
        searchable: true
      },
      likes_count: %{
        label: "Likes",
        sortable: true,
        searchable: false
      },
      repost_count: %{
        label: "Reposts",
        sortable: true,
        searchable: false
      },
      photo_locations: %{
        label: "Photos",
        sortable: false,
        searchable: false
      }
    ]
  end

  def sort_link(assigns) do
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

  defp next_sort_order("asc"), do: "desc"
  defp next_sort_order("desc"), do: "asc"
end
