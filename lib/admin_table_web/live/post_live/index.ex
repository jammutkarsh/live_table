defmodule AdminTableWeb.PostLive.Index do
  use AdminTableWeb, :live_view

  use AdminTableWeb.LiveResource, schema: AdminTable.Timeline.Post, resource: "posts"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
end
