defmodule DemoWeb.BasicTableLive do
  use DemoWeb, :live_view

  use LiveTable.LiveResource, schema: Demo.HR.Employee

  def mount(_params, _session, socket) do
    socket = socket |> assign(:page_title, "Basic Table Demo")
    {:ok, socket}
  end

  def fields do
    [
      id: %{
        label: "ID",
        sortable: true
      },
      name: %{
        label: "Name",
        sortable: true
      },
      email: %{
        label: "Email",
        sortable: true
      },
      department: %{
        label: "Department",
        sortable: true
      },
      level: %{
        label: "Level",
        sortable: true
      }
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-1">
        <h1 class="text-2xl font-semibold mb-4 dark:text-white">Basic Table Demo</h1>
        <p class="text-gray-600 mb-6 dark:text-gray-300">
          Demonstrates basic LiveTable features: sorting and pagination.
          Click on column headers to sort, use shift+click for multi-column sort.
        </p>

        <.live_table
          fields={fields()}
          filters={filters()}
          options={@options}
          streams={@streams}
        />
      </div>
    </div>
    """
  end
end
