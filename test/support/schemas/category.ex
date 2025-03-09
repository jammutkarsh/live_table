defmodule LiveTable.Catalog.Category do
  use Ecto.Schema

  schema "categories" do
    field :name, :string
    field :description, :string

    has_many :products, LiveTable.Catalog.Product

    timestamps(type: :utc_datetime)
  end
end
