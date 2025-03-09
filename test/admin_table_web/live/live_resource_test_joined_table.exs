# # admin_table/test/admin_table_web/live_resource_test.exs

# defmodule AdminTableWeb.LiveResourceTest do
#   use AdminTable.DataCase

#   import AdminTable.CatalogFixtures

#   defmodule TestResource do
#     use AdminTableWeb.LiveResource, schema: AdminTable.Catalog.Product

#     def fields do
#       [
#         id: %{
#           label: "ID",
#           sortable: true,
#           searchable: false
#         },
#         name: %{
#           label: "Product Name",
#           sortable: true,
#           searchable: true
#         },
#         category_name: %{
#           label: "Category Name",
#           assoc: {:category, :name},
#           searchable: false,
#           sortable: true
#         },
#         supplier_name: %{
#           label: "Supplier Name",
#           assoc: {:suppliers, :name},
#           searchable: true,
#           sortable: true
#         }
#       ]
#     end

#     def filters do
#       import AdminTable.Boolean
#       import Ecto.Query

#       [
#         price:
#           new(:price, "under-100", %{
#             label: "Under 100",
#             condition: dynamic([p], p.price < 100)
#           })
#       ]
#     end
#   end

#   setup do
#     category = category_fixture()
#     supplier = supplier_fixture()

#     product =
#       product_fixture(%{
#         category_id: category.id,
#         name: "Test Product",
#         description: "Test Description",
#         price: "100.00"
#       })

#     # Associate product with supplier
#     Repo.insert_all("products_suppliers", [
#       %{
#         product_id: product.id,
#         supplier_id: supplier.id,
#         inserted_at: NaiveDateTime.utc_now(),
#         updated_at: NaiveDateTime.utc_now()
#       }
#     ])

#     %{
#       product: product,
#       category: category,
#       supplier: supplier
#     }
#   end

#   describe "list_resources/2" do
#     test "returns products with basic sorting", %{product: product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => true,
#           "sort_params" => [%{"sort_by" => "name", "sort_order" => "asc"}]
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) > 0
#       assert Enum.find(results, &(&1.id == product.id))
#     end

#     test "returns products with pagination", %{product: product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => true,
#           "page" => "1",
#           "per_page" => "5"
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) <= 5
#       assert Enum.find(results, &(&1.id == product.id))
#     end

#     test "includes associated data in results", %{
#       product: product,
#       category: category,
#       supplier: supplier
#     } do
#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       result = Enum.find(results, &(&1.id == product.id))

#       assert result.category_name == category.name
#       assert result.supplier_name == supplier.name
#     end

#     test "handles descending sort order", %{product: product} do
#       # Create another product to test sorting
#       _product2 = product_fixture(%{name: "AAA Test Product"})

#       options = %{
#         "sort" => %{
#           "sortable?" => true,
#           "sort_params" => [%{"sort_by" => "name", "sort_order" => "desc"}]
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       [first | _] = results

#       # The product with name "Test Product" should come before "AAA Test Product"
#       assert first.name == product.name
#     end

#     test "combines sorting and pagination", %{product: product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => true,
#           "sort_params" => [%{"sort_by" => "name", "sort_order" => "asc"}]
#         },
#         "pagination" => %{
#           "paginate?" => true,
#           "page" => "1",
#           "per_page" => "2"
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) <= 2
#       assert Enum.find(results, &(&1.id == product.id))
#     end

#     test "handles sorting and pagination for joined tables", %{product: product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => true,
#           "sort_params" => [%{"sort_by" => "category_name", "sort_order" => "asc"}]
#         },
#         "pagination" => %{
#           "paginate?" => true,
#           "page" => "1",
#           "per_page" => "2"
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)

#       assert length(results) <= 2

#       sorted_results = Enum.sort_by(results, & &1.category_name, &<=/2)
#       assert results == sorted_results
#       assert Enum.any?(results, &(&1.id == product.id))
#     end

#     test "handles sorting by more than 1 field", %{product: product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => true,
#           "sort_params" => [
#             %{"sort_by" => "category_name", "sort_order" => "asc"},
#             %{"sort_by" => "supplier_name", "sort_order" => "asc"}
#           ]
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{}
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)

#       sorted_results =
#         Enum.sort_by(
#           results,
#           fn result -> {result.category_name, result.supplier_name} end,
#           &<=/2
#         )

#       assert results == sorted_results
#       assert Enum.any?(results, &(&1.id == product.id))
#     end

#     test "handles text search for searchable columns", %{product: product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "search" => "Test"
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) > 0
#       assert Enum.find(results, &(&1.id == product.id))
#     end

#     test "avoids text search for non-searchable columns", %{product: _product} do
#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "search" => "some category"
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) == 0
#     end

#     test "applies boolean filters to query", %{product: _product} do
#       expensive_product = product_fixture(%{name: "Expensive", price: "150.00"})
#       cheap_product = product_fixture(%{name: "Cheap", price: "50.00"})

#       price_filter = TestResource.filters()[:price]

#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "under-100" => price_filter,
#           "search" => ""
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)

#       # Should not include expensive product since we filtered for under 100
#       assert length(results) == 1
#       assert hd(results).id == cheap_product.id
#       refute Enum.find(results, &(&1.id == expensive_product.id))
#     end

#     test "combines boolean and text search filters", %{product: _product} do
#       # Create products with different prices
#       _expensive_product = product_fixture(%{name: "Bargain Item", price: "150.00"})
#       cheap_product = product_fixture(%{name: "Bargain Item", price: "50.00"})

#       price_filter = TestResource.filters()[:price]

#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "under-100" => price_filter,
#           "search" => "Bargain"
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)

#       # Should only find cheap bargain item
#       assert length(results) == 1
#       assert hd(results).id == cheap_product.id
#     end

#     test "applies multiple boolean filters", %{product: _product, supplier: supplier} do
#       # Create products with different prices but same supplier
#       cheap_product = product_fixture(%{name: "Cheap", price: "50.00"})
#       expensive_product = product_fixture(%{name: "Expensive", price: "150.00"})

#       # Associate both with supplier
#       Repo.insert_all("products_suppliers", [
#         %{
#           product_id: expensive_product.id,
#           supplier_id: supplier.id,
#           inserted_at: NaiveDateTime.utc_now(),
#           updated_at: NaiveDateTime.utc_now()
#         },
#         %{
#           product_id: cheap_product.id,
#           supplier_id: supplier.id,
#           inserted_at: NaiveDateTime.utc_now(),
#           updated_at: NaiveDateTime.utc_now()
#         }
#       ])

#       price_filter = TestResource.filters()[:price]

#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "under-100" => price_filter
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)

#       assert length(results) == 1
#       assert hd(results).id == cheap_product.id
#       refute Enum.find(results, &(&1.id == expensive_product.id))
#     end
#   end
# end
