defmodule AdminTable.FilterTest do
  use AdminTable.DataCase
  import Ecto.Query
  alias AdminTable.Join
  alias AdminTable.Catalog.{Product, Category, Image, Supplier}

  describe "apply_text_search/3" do
    test "returns query when search term is empty" do
      query = from(p in Product, as: :resource)
      fields = %{name: %{searchable: true}}

      result = AdminTable.Filter.apply_text_search(query, "", fields)

      assert result == query
    end

    test "applies text search to query in base schema" do
      query = from(p in Product, as: :resource)

      fields = [
        name: %{searchable: true},
        description: %{searchable: true}
      ]

      result = AdminTable.Filter.apply_text_search(query, "search term", fields)

      assert inspect(result) =~ "where: ilike(p0.name, ^\"%search term%\")"
      assert inspect(result) =~ "ilike(p0.description, ^\"%search term%\")"
    end

    test "applies text search to query to joined query" do
      query =
        from p0 in AdminTable.Catalog.Product,
          as: :resource,
          left_join: s1 in assoc(p0, :suppliers),
          as: :suppliers,
          left_join: c2 in assoc(p0, :category),
          as: :category,
          select: %{
            name: p0.name,
            supplier_name: s1.name,
            category_name: c2.name
          }

      fields = [
        name: %{searchable: true},
        supplier_name: %{assoc: {:suppliers, :name}, searchable: true},
        category_name: %{assoc: {:category, :name}, searchable: true}
      ]

      result = AdminTable.Filter.apply_text_search(query, "search term", fields)

      assert inspect(result) =~ "where: ilike(p0.name, ^\"%search term%\")"
      assert inspect(result) =~ "ilike(s1.name, ^\"%search term%\")"
      assert inspect(result) =~ "ilike(c2.name, ^\"%search term%\")"
    end

    test "doesn't apply search to non-searchable column" do
      query =
        from p0 in AdminTable.Catalog.Product,
          as: :resource,
          left_join: s1 in assoc(p0, :suppliers),
          as: :suppliers

      fields = [
        name: %{searchable: true},
        description: %{searchable: false},
        supplier_name: %{assoc: {:suppliers, :name}, searchable: false}
      ]

      result = AdminTable.Filter.apply_text_search(query, "search term", fields)

      assert inspect(result) =~ "where: ilike(p0.name, ^\"%search term%\")"
      refute inspect(result) =~ "ilike(p0.description, ^\"%search term%\")"
      refute inspect(result) =~ "ilike(s1.name, ^\"%search term%\")"
    end
  end
end
