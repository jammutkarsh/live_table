defmodule LiveTable.Catalog.Product do
  use Ecto.Schema

  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :stock_quantity, :integer

    belongs_to :category, LiveTable.Catalog.Category

    many_to_many :suppliers, LiveTable.Catalog.Supplier,
      join_through: "products_suppliers",
      on_replace: :delete

    has_one :image, LiveTable.Catalog.Image
    timestamps(type: :utc_datetime)
  end
end
