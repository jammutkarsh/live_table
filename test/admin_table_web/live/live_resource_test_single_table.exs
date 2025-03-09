# defmodule TestWeb.LiveResourceTest do
#   use AdminTable.DataCase
#   alias AdminTable.{Timeline.Post, Repo}
#   alias AdminTable.Catalog.{Product, Category, Supplier, Image}

#   import AdminTable.TimelineFixtures

#   defmodule TestResource do
#     use AdminTableWeb.LiveResource,
#       schema: AdminTable.Timeline.Post

#     def fields do
#       [
#         id: %{sortable: true, searchable: false},
#         body: %{sortable: true, searchable: true},
#         likes_count: %{sortable: true, searchable: false},
#         repost_count: %{sortable: false, searchable: false}
#       ]
#     end
#   end

#   setup do
#     post1 =
#       post_fixture(%{
#         body: "B Post",
#         likes_count: 10,
#         repost_count: 5,
#         photo_locations: ["location1"]
#       })

#     post2 =
#       post_fixture(%{
#         body: "A Post",
#         likes_count: 20,
#         repost_count: 8,
#         photo_locations: ["location2"]
#       })

#     post3 =
#       post_fixture(%{
#         body: "C Post",
#         likes_count: 15,
#         repost_count: 3,
#         photo_locations: ["location3"]
#       })

#     %{posts: [post1, post2, post3]}
#   end

#   describe "Sorting" do
#     test "list_resources returns all resources without sorting", %{posts: posts} do
#       fields = TestResource.fields()
#       options = %{"sort" => %{"sortable?" => false}, "pagination" => %{"paginate?" => false}}
#       results = TestResource.list_resources(fields, options)

#       assert length(results) == 3

#       assert Enum.map(results, & &1.id) |> Enum.sort() ==
#                Enum.map(posts, & &1.id) |> Enum.sort()
#     end

#     test "list_resources sorts by body ascending", %{posts: _posts} do
#       fields = TestResource.fields()

#       options = %{
#         "sort" => %{
#           "sort_params" => [body: :asc],
#           "sortable?" => true
#         },
#         "pagination" => %{"paginate?" => false}
#       }

#       results = TestResource.list_resources(fields, options)
#       bodies = Enum.map(results, & &1.body)
#       assert bodies == ["A Post", "B Post", "C Post"]
#     end

#     test "list_resources sorts by body descending", %{posts: _posts} do
#       fields = TestResource.fields()

#       options = %{
#         "sort" => %{
#           "sort_params" => [body: :desc],
#           "sortable?" => true
#         },
#         "pagination" => %{"paginate?" => false}
#       }

#       results = TestResource.list_resources(fields, options)
#       bodies = Enum.map(results, & &1.body)
#       assert bodies == ["C Post", "B Post", "A Post"]
#     end

#     test "list_resources sorts by likes_count ascending", %{posts: _posts} do
#       fields = TestResource.fields()

#       options = %{
#         "sort" => %{
#           "sort_params" => [likes_count: :asc],
#           "sortable?" => true
#         },
#         "pagination" => %{"paginate?" => false}
#       }

#       results = TestResource.list_resources(fields, options)
#       likes = Enum.map(results, & &1.likes_count)
#       assert likes == [10, 15, 20]
#     end

#     test "list_resources with non-sortable field returns unsorted results", %{posts: posts} do
#       fields = TestResource.fields()

#       options = %{
#         "sort" => %{
#           "sort_params" => [repost_count: :asc],
#           "sortable?" => true
#         },
#         "pagination" => %{"paginate?" => false}
#       }

#       results = TestResource.list_resources(fields, options)
#       assert length(results) == 3

#       assert Enum.map(results, & &1.id) |> Enum.sort() ==
#                Enum.map(posts, & &1.id) |> Enum.sort()
#     end
#   end

#   describe "Pagination" do
#     test "list_resources returns all resources when no pagination", %{posts: posts} do
#       fields = TestResource.fields()

#       options = %{
#         "sort" => %{"sortable?" => false},
#         "pagination" => %{"paginate?" => false}
#       }

#       results = TestResource.list_resources(fields, options)
#       assert length(results) == 3
#       assert Enum.map(results, & &1.body) == Enum.map(posts, & &1.body)
#     end

#     test "list_resources with pagination returns paginated results" do
#       options = %{
#         "sort" => %{"sortable?" => false},
#         "pagination" => %{
#           "paginate?" => true,
#           "per_page" => "1",
#           "page" => "1"
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) == 1
#     end

#     test "fields returns defined fields" do
#       assert TestResource.fields() == [
#                {:id, %{sortable: true, searchable: false}},
#                {:body, %{sortable: true, searchable: true}},
#                {:likes_count, %{sortable: true, searchable: false}},
#                {:repost_count, %{sortable: false, searchable: false}}
#              ]
#     end
#   end

#   describe "Filters" do
#     test "handles text search for searchable columns", %{posts: _posts} do
#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "search" => "A Post"
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)

#       assert length(results) == 1
#       assert Enum.find(results, &(&1.body == "A Post"))
#     end

#     test "avoids text search for non-searchable columns", %{posts: _posts} do
#       options = %{
#         "sort" => %{
#           "sortable?" => false
#         },
#         "pagination" => %{
#           "paginate?" => false
#         },
#         "filters" => %{
#           "search" => "some body"
#         }
#       }

#       results = TestResource.list_resources(TestResource.fields(), options)
#       assert length(results) == 0
#     end
#   end
# end
