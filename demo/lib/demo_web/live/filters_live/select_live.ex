defmodule DemoWeb.Filters.SelectLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, schema: Demo.Catalog.Product
  alias LiveTable.Select
  alias Demo.Catalog

  def fields do
    [
      name: %{
        label: "Product",
        sortable: true
      },
      price: %{
        label: "Price",
        sortable: true
      },
      category: %{
        label: "Category",
        sortable: true,
        # Join with categories
        assoc: {:category, :name}
      },
      supplier: %{
        label: "Supplier",
        sortable: true,
        assoc: {:suppliers, :name}
      },
      stock_quantity: %{
        label: "Stock",
        sortable: true
      }
    ]
  end

  def filters do
    [
      supplier:
        Select.new({:suppliers, :name}, "supplier", %{
          label: "Major Suppliers",
          options: [
            %{label: "AutoParts Direct", value: [1, "Major automotive supplier"]},
            %{label: "Tech Solutions Inc", value: [2, "Electronics manufacturer"]},
            %{label: "Global Foods Ltd", value: [3, "International food distributor"]}
          ]
        }),
      category:
        Select.new({:category, :name}, "category", %{
          label: "Category",
          options_source: {Catalog, :search_categories, []}
        })
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-8">
        <h1 class="text-2xl font-semibold mb-4 dark:text-white">Select Filters Demo</h1>
        <p class="text-gray-600 mb-6">
          Demonstrates select filter capabilities. Features:
          <ul class="list-disc list-inside mt-2">
            <li>Static select options (Price Range)</li>
            <li>Dynamic select options (Categories)</li>
            <li>Searchable select with live updates</li>
            <li>Custom option templates</li>
          </ul>
        </p>

        <.live_table fields={fields()} filters={filters()} options={@options} streams={@streams} />
      </div>
    </div>
    """
  end
end
