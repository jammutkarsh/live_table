defmodule AdminTable.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AdminTable.Catalog` context.
  """
  alias AdminTable.Catalog.{Category, Supplier}
  alias AdminTable.Repo

  @doc """
  Generate a product.
  """

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: "120.5",
        stock_quantity: 42
      })
      |> AdminTable.Catalog.create_product()

    product
  end

  def category_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })

    changeset = Category.changeset(%Category{}, attrs)

    {:ok, category} =
      Repo.insert(changeset)

    category
  end

  def supplier_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "some name",
        contact_info: "some contact info"
      })

    changeset = Supplier.changeset(%Supplier{}, attrs)

    {:ok, category} =
      Repo.insert(changeset)

    category
  end
end
