defmodule DemoWeb.SearchLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, resource: "search", schema: Demo.Catalog.Product

  def fields do
    [
      name: %{
        label: "Product Name",
        sortable: true,
        searchable: true  # Enable search on product name
      },
      description: %{
        label: "Description",
        sortable: false,
        searchable: true  # Enable search on description
      },
      supplier_name: %{
        label: "Supplier",
        sortable: true,
        searchable: true,  # Enable search on supplier name
        assoc: {:suppliers, :name}
      },
      category_name: %{
        label: "Category",
        sortable: true,
        searchable: true,  # Enable search on category name
        assoc: {:category, :name}
      },
      price: %{
        label: "Price",
        sortable: true,
        searchable: false  # Numeric field, not searchable
      }
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-1">
        <h1 class="text-2xl font-semibold mb-4">Search Functionality Demo</h1>
        <p class="text-gray-600 mb-6 dark:text-white">
          Demonstrates full-text search capabilities. Features:
          <ul class="list-disc list-inside mt-2">
            <li>Search across multiple fields (name, description)</li>
            <li>Search across joined tables (suppliers, categories)</li>
            <li>Real-time search results</li>
            <li>Case-insensitive search</li>
            <li>Partial word matching</li>
          </ul>
        </p>

        <div class="mb-6 text-sm text-gray-500">
          Try searching for:
          <ul class="list-disc list-inside mt-2 space-y-1">
            <li>Product names or partial names</li>
            <li>Words from product descriptions</li>
            <li>Supplier names</li>
            <li>Category names</li>
          </ul>
        </div>

        <.live_table
          fields={fields()}
          filters={filters()}
          options={@options}
          streams={@streams}
          table_options={table_options()}
        />
      </div>
    </div>
    """
  end

  def table_options() do
    %{
      exports: %{enabled: false}
    }
  end
end
