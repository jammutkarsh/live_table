defmodule DemoWeb.Filters.BooleanLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, resource: "boolean", schema: Demo.Catalog.Product
  alias LiveTable.Boolean

  def fields do
    [
      name: %{
        label: "Product Name",
        sortable: true
      },
      price: %{
        label: "Price",
        sortable: true
      },
      active: %{
        label: "Active",
        sortable: true
      },
      featured: %{
        label: "Featured",
        sortable: true
      },
      in_stock: %{
        label: "In Stock",
        sortable: true
      }
    ]
  end

  def filters do
    [
      active: Boolean.new(:active, "active", %{
        label: "Active Products Only",
        condition: dynamic([p], p.active == true)
      }),

      featured: Boolean.new(:featured, "featured", %{
        label: "Featured Products",
        condition: dynamic([p], p.featured == true)
      }),

      in_stock: Boolean.new(:in_stock, "in_stock", %{
        label: "In Stock Only",
        condition: dynamic([p], p.in_stock == true)
      })
    ]
  end


  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-1">
        <h1 class="text-2xl font-semibold mb-4">Boolean Filters Demo</h1>
        <p class="text-gray-600 mb-6">
          Demonstrates boolean filter capabilities. Try combining multiple filters:
          <ul class="list-disc list-inside mt-2">
            <li>Active products only</li>
            <li>Featured products</li>
            <li>In-stock products</li>
          </ul>
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
