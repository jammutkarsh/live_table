# admin_table/test/admin_table_web/live_resource_test.exs

defmodule AdminTableWeb.LiveResourceTest do
  use AdminTable.DataCase

  import AdminTable.CatalogFixtures

  defmodule TestResource do
    use AdminTableWeb.LiveResource, schema: AdminTable.Catalog.Product

    def fields do
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
        category_name: %{
          label: "Category Name",
          assoc: {:category, :name},
          searchable: false,
          sortable: false
        },
        supplier_name: %{
          label: "Supplier Name",
          assoc: {:suppliers, :name},
          searchable: true,
          sortable: false
        }
      ]
    end
  end

  setup do
    category = category_fixture()
    supplier = supplier_fixture()

    product =
      product_fixture(%{
        category_id: category.id,
        name: "Test Product",
        description: "Test Description",
        price: "100.00"
      })

    # Associate product with supplier
    Repo.insert_all("products_suppliers", [
      %{
        product_id: product.id,
        supplier_id: supplier.id,
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      }
    ])

    %{
      product: product,
      category: category,
      supplier: supplier
    }
  end

  describe "list_resources/2" do
    test "returns products with basic sorting", %{product: product} do
      options = %{
        "sort" => %{
          "sortable?" => true,
          "sort_by" => "name",
          "sort_order" => "asc"
        },
        "pagination" => %{
          "paginate?" => false
        }
      }

      results = TestResource.list_resources(TestResource.fields(), options)
      assert length(results) > 0
      assert Enum.find(results, &(&1.id == product.id))
    end

    test "returns products with pagination", %{product: product} do
      options = %{
        "sort" => %{
          "sortable?" => false
        },
        "pagination" => %{
          "paginate?" => true,
          "page" => "1",
          "per_page" => "5"
        }
      }

      results = TestResource.list_resources(TestResource.fields(), options)
      assert length(results) <= 5
      assert Enum.find(results, &(&1.id == product.id))
    end

    test "includes associated data in results", %{
      product: product,
      category: category,
      supplier: supplier
    } do
      options = %{
        "sort" => %{
          "sortable?" => false
        },
        "pagination" => %{
          "paginate?" => false
        }
      }

      results = TestResource.list_resources(TestResource.fields(), options)
      result = Enum.find(results, &(&1.id == product.id))

      assert result.category_name == category.name
      assert result.supplier_name == supplier.name
    end

    test "handles descending sort order", %{product: product} do
      # Create another product to test sorting
      product2 = product_fixture(%{name: "AAA Test Product"})

      options = %{
        "sort" => %{
          "sortable?" => true,
          "sort_by" => "name",
          "sort_order" => "desc"
        },
        "pagination" => %{
          "paginate?" => false
        }
      }

      results = TestResource.list_resources(TestResource.fields(), options)
      [first | _] = results

      # The product with name "Test Product" should come before "AAA Test Product"
      assert first.name == product.name
    end

    test "combines sorting and pagination", %{product: product} do
      options = %{
        "sort" => %{
          "sortable?" => true,
          "sort_by" => "name",
          "sort_order" => "asc"
        },
        "pagination" => %{
          "paginate?" => true,
          "page" => "1",
          "per_page" => "2"
        }
      }

      results = TestResource.list_resources(TestResource.fields(), options)
      assert length(results) <= 2
      assert Enum.find(results, &(&1.id == product.id))
    end
  end
end
