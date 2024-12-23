defmodule AdminTable.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :stock_quantity, :integer

    belongs_to :category, AdminTable.Catalog.Category

    many_to_many :suppliers, AdminTable.Catalog.Supplier,
      join_through: "products_suppliers",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :stock_quantity])
    |> validate_required([:name, :description, :price, :stock_quantity])
  end
end
