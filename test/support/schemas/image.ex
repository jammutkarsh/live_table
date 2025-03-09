defmodule LiveTable.Catalog.Image do
  use Ecto.Schema

  schema "images" do
    field :url, :string
    belongs_to :product, LiveTable.Catalog.Product

    timestamps(type: :utc_datetime)
  end


end
