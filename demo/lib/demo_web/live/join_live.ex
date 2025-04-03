defmodule DemoWeb.JoinLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, schema: Demo.Catalog.Product

  def fields do
    [
      name: %{
        label: "Product",
        sortable: true
      },
      # One-to-many join (Product belongs_to Category)
      category_name: %{
        label: "Category",
        sortable: true,
        assoc: {:category, :name}
      },
      # Many-to-many join (Product many_to_many Suppliers)
      supplier_count: %{
        label: "Supplier Count",
        sortable: true,
        assoc: {:suppliers, :name},
        computed:
          dynamic(
            [resource: p],
            fragment("(SELECT COUNT(*) FROM products_suppliers WHERE product_id = ?)", p.id)
          )
      },
      # Computed field using price and stock
      total_value: %{
        label: "Total Value",
        sortable: true,
        computed: dynamic([resource: p], fragment("? * ?", p.price, p.stock_quantity))
      },
      # One-to-one join (Product has_one Image)
      image_url: %{
        label: "Image URL",
        sortable: false,
        assoc: {:image, :url}
      },
      # Multiple joins combined
      category_supplier_info: %{
        label: "Category-Supplier Info",
        sortable: false,
        computed:
          dynamic(
            [resource: p, category: c],
            fragment(
              "? || ' (' || (SELECT COUNT(*) FROM products_suppliers WHERE product_id = ?) || ' suppliers)'",
              c.name,
              p.id
            )
          )
      }
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 dark:bg-neutral-900">
      <div class="py-8">
        <h1 class="text-2xl font-semibold mb-4 dark:text-neutral-100">Table Joins Demo</h1>
        <p class="text-gray-600 dark:text-neutral-400 mb-6">
          Demonstrates different types of table joins and computed fields. Features:
          <ul class="list-disc list-inside mt-2 dark:text-neutral-300">
            <li>One-to-many join (Products → Categories)</li>
            <li>Many-to-many join (Products ↔ Suppliers)</li>
            <li>One-to-one join (Products → Image)</li>
            <li>Computed fields across joins</li>
            <li>Aggregations (supplier count)</li>
            <li>Complex computed fields (total value)</li>
          </ul>
        </p>

        <.live_table fields={fields()} filters={filters()} options={@options} streams={@streams} />
      </div>
    </div>
    """
  end
end
