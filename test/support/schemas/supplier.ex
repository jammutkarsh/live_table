defmodule LiveTable.Catalog.Supplier do
  use Ecto.Schema

  schema "suppliers" do
    field :name, :string
    field :contact_info, :string
    field :address, :string

    many_to_many :products, LiveTable.Catalog.Product,
      join_through: "products_suppliers",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end
end
