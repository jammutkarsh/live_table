defmodule LiveTable.JoinTest do
  use LiveTable.DataCase
  alias LiveTable.{Catalog.Product, Join}

  describe "join_associations/2" do
    test "adds correct joins for single association" do
      fields = %{
        name: %{},
        category_name: %{assoc: {:category, :name}}
      }

      query = from(p in Product, as: :resource)
      result = Join.join_associations(query, fields)

      assert inspect(result) =~ "left_join: c1 in assoc(p0, :category)"
    end

    test "adds multiple joins for different associations" do
      fields = %{
        name: %{},
        category_name: %{assoc: {:category, :name}},
        image_url: %{assoc: {:image, :url}}
      }

      query = from(p in Product, as: :resource)
      result = Join.join_associations(query, fields)

      assert inspect(result) =~ "left_join: c1 in assoc(p0, :category)"
      assert inspect(result) =~ "left_join: i2 in assoc(p0, :image)"
    end

    test "joins one-to-many association (product -> category)" do
      fields = [
        category_name: %{
          label: "Category Name",
          assoc: {:category, :name}
        }
      ]

      query = Product |> from(as: :resource)
      result = Join.join_associations(query, fields)

      assert inspect(result) =~ "left_join: c1 in assoc(p0, :category)"
    end

    test "joins many-to-many association (product -> suppliers)" do
      fields = [
        supplier_name: %{
          label: "Supplier Name",
          assoc: {:suppliers, :name}
        }
      ]

      query = Product |> from(as: :resource)
      result = Join.join_associations(query, fields)

      assert inspect(result) =~ "left_join: s1 in assoc(p0, :suppliers)"
    end

    test "joins has_one association (product -> image)" do
      fields = [
        image_url: %{
          label: "Image URL",
          assoc: {:image, :url}
        }
      ]

      query = Product |> from(as: :resource)
      result = Join.join_associations(query, fields)

      assert inspect(result) =~ "left_join: i1 in assoc(p0, :image)"
    end

    test "joins multiple associations" do
      fields = [
        category_name: %{
          label: "Category Name",
          assoc: {:category, :name}
        },
        supplier_name: %{
          label: "Supplier Name",
          assoc: {:suppliers, :name}
        },
        image_url: %{
          label: "Image URL",
          assoc: {:image, :url}
        }
      ]

      query = Product |> from(as: :resource)
      result = Join.join_associations(query, fields)

      assert inspect(result) =~ "left_join: c1 in assoc(p0, :category)"
      assert inspect(result) =~ "left_join: s2 in assoc(p0, :suppliers)"
      assert inspect(result) =~ "left_join: i3 in assoc(p0, :image)"
    end

    test "doesn't duplicate joins for the same association" do
      fields = [
        supplier_name: %{
          label: "Supplier Name",
          assoc: {:suppliers, :name}
        },
        supplier_contact: %{
          label: "Supplier Contact",
          assoc: {:suppliers, :contact_info}
        }
      ]

      query = Product |> from(as: :resource)
      result = Join.join_associations(query, fields)

      # Count occurrences of the suppliers join
      joins_count =
        result
        |> inspect()
        |> String.split("left_join")
        |> length()
        # Subtract 1 for the initial part before first join
        |> Kernel.-(1)

      assert joins_count == 1
    end
  end

  describe "select_columns/2" do
    test "builds correct select statement for direct fields" do
      fields = %{
        name: %{},
        price: %{}
      }

      query = from(p in Product, as: :resource)
      result = Join.select_columns(query, fields)
      assert inspect(result) =~ "select: %{name: p0.name, price: p0.price}"
    end

    test "selects fields from main resource and associations" do
      fields = [
        name: %{label: "Name"},
        category_name: %{
          label: "Category Name",
          assoc: {:category, :name}
        },
        supplier_name: %{
          label: "Supplier Name",
          assoc: {:suppliers, :name}
        }
      ]

      query = Product |> from(as: :resource)
      query = Join.join_associations(query, fields)
      result = Join.select_columns(query, fields)

      {_, _, select_struct} = result.select.expr
      select_struct = Enum.into(select_struct, %{})
      assert Map.has_key?(select_struct, :name)
      assert Map.has_key?(select_struct, :category_name)
      assert Map.has_key?(select_struct, :supplier_name)
    end

    test "handles multiple associations in select" do
      fields = %{
        name: %{},
        category_name: %{assoc: {:category, :name}},
        image_url: %{assoc: {:image, :url}}
      }

      query = from(p in Product, as: :resource)
      query = Join.join_associations(query, fields)
      result = Join.select_columns(query, fields)

      assert inspect(result) =~
               "select: %{name: p0.name, category_name: c1.name, image_url: i2.url}"
    end

    test "handles multiple fields from the same association" do
      fields = [
        supplier_name: %{
          label: "Supplier Name",
          assoc: {:suppliers, :name}
        },
        supplier_contact: %{
          label: "Supplier Contact",
          assoc: {:suppliers, :contact_info}
        }
      ]

      query = Product |> from(as: :resource)
      query = Join.join_associations(query, fields)
      result = Join.select_columns(query, fields)

      {_, _, select_struct} = result.select.expr
      select_struct = Enum.into(select_struct, %{})

      assert Map.has_key?(select_struct, :supplier_name)
      assert Map.has_key?(select_struct, :supplier_contact)
    end
  end

  # Integration test
  describe "integration" do
    test "builds complete query with joins and selects" do
      fields = %{
        name: %{},
        price: %{},
        category_name: %{assoc: {:category, :name}},
        image_url: %{assoc: {:image, :url}}
      }

      query = from(p in Product, as: :resource)

      result =
        query
        |> Join.join_associations(fields)
        |> Join.select_columns(fields)

      # Verify joins
      assert inspect(result) =~ "left_join: c1 in assoc(p0, :category)"
      assert inspect(result) =~ "left_join: i2 in assoc(p0, :image)"

      # Verify complete select structure
      assert inspect(result) =~ "name: p0.name"
      assert inspect(result) =~ "category_name: c1.name"
      assert inspect(result) =~ "image_url: i2.url"
      assert inspect(result) =~ "price: p0.price"
    end
  end
end
