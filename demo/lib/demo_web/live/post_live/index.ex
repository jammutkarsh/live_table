defmodule DemoWeb.PostLive.Index do
  use DemoWeb, :live_view

  use LiveTable.LiveResource,
    schema: Demo.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Listing Posts")}
  end

  def fields() do
    [
      id: %{label: "ID", sortable: true},
      body: %{label: "Body", sortable: true},
      likes_count: %{label: "Likes count", sortable: true},
      repost_count: %{label: "Repost count", sortable: true}
    ]
  end

  def table_options do
    %{pagination: %{enabled: true, sizes: [5, 10, 100]}, exports: %{enabled: false}}
  end
end
