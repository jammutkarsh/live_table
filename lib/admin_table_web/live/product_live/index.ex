defmodule AdminTableWeb.ProductLive.Index do
  use AdminTableWeb, :live_view
  alias AdminTable.{Boolean, Range, Select}

  use AdminTableWeb.LiveResource, schema: AdminTable.Catalog.Product, resource: "products"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AdminTable.PubSub, "exports")
    end

    {:ok, socket |> assign(:page_title, "Listing Products")}
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
        searchable: false
      },
      price: %{
        label: "Price",
        sortable: true,
        searchable: false
      },
      supplier_name: %{
        label: "Supplier Name",
        assoc: {:suppliers, :name},
        searchable: false,
        sortable: false
      },
      supplier_description: %{
        label: "Supplier Email",
        assoc: {:suppliers, :contact_info},
        searchable: false,
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
        searchable: false,
        sortable: true
      },
      image: %{
        label: "Image",
        sortable: false,
        searchable: false,
        assoc: {:image, :url}
      },
      amount: %{
        label: "Amount",
        sortable: true,
        searchable: false,
        computed: dynamic([resource: r], fragment("? * ?", r.price, r.stock_quantity))
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
          %{
            label: "Email",
            condition: dynamic([p, s], s.contact_info == "procurement@autopartsdirect.com")
          }
        ),
      prices:
        Range.new(:price, "10-to-100", %{label: "Enter range", min: 0, max: 500, unit: "$"}),
      supplier_name:
        Select.new({:suppliers, :name}, "suppliser_name", %{
          label: "Supplier",
          placeholder: "Search for suppliers...",
          options_source: {AdminTable.Catalog, :search_suppliers, []}
          # options: [{"Auto Parts Direct", ["id"]}],
          # option_template: &custom_template/1,
        })
    ]
  end

  # def custom_template(option) do
  #   assigns = %{option: option}
  #   ~H"""
  #   <div class="flex flex-col">
  #     <span class="font-bold"><%= @option.label %></span> inas
  #     <span class="text-sm text-gray-500"><%= @option.value |> Enum.at(0) %></span>
  #   </div>
  #   """
  # end
end
