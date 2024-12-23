defmodule TestWeb.LiveResourceTest do
  use AdminTable.DataCase
  alias AdminTable.{Timeline.Post, Repo}

  defmodule TestResource do
    use TestWeb.LiveResource,
      schema: AdminTable.Timeline.Post

    def fields do
      [
        id: [sortable?: true],
        body: [sortable?: true],
        likes_count: [sortable?: true],
        repost_count: [sortable?: false]
      ]
    end
  end

  describe "LiveResource" do
    setup do
      # Setup test data with relevant fields
      {:ok, post1} =
        Repo.insert(%Post{
          body: "B Post",
          likes_count: 10,
          repost_count: 5,
          photo_locations: ["location1"]
        })

      {:ok, post2} =
        Repo.insert(%Post{
          body: "A Post",
          likes_count: 20,
          repost_count: 8,
          photo_locations: ["location2"]
        })

      {:ok, post3} =
        Repo.insert(%Post{
          body: "C Post",
          likes_count: 15,
          repost_count: 3,
          photo_locations: ["location3"]
        })

      %{posts: [post1, post2, post3]}
    end

    test "list_resources returns all resources without sorting", %{posts: posts} do
      fields = TestResource.fields()
      options = %{"sort" => %{"sortable?" => false}}
      results = TestResource.list_resources(fields, options)
      assert length(results) == 3

      assert Enum.map(results, & &1.id) |> Enum.sort() ==
               Enum.map(posts, & &1.id) |> Enum.sort()
    end

    test "list_resources sorts by body ascending", %{posts: _posts} do
      fields = TestResource.fields()

      options = %{
        "sort" => %{
          "sort_by" => "body",
          "sort_order" => "asc",
          "sortable?" => true
        }
      }

      results = TestResource.list_resources(fields, options)
      bodies = Enum.map(results, & &1.body)
      assert bodies == ["A Post", "B Post", "C Post"]
    end

    test "list_resources sorts by body descending", %{posts: _posts} do
      fields = TestResource.fields()

      options = %{
        "sort" => %{
          "sort_by" => "body",
          "sort_order" => "desc",
          "sortable?" => true
        }
      }

      results = TestResource.list_resources(fields, options)
      bodies = Enum.map(results, & &1.body)
      assert bodies == ["C Post", "B Post", "A Post"]
    end

    test "list_resources sorts by likes_count ascending", %{posts: _posts} do
      fields = TestResource.fields()

      options = %{
        "sort" => %{
          "sort_by" => "likes_count",
          "sort_order" => "asc",
          "sortable?" => true
        }
      }

      results = TestResource.list_resources(fields, options)
      likes = Enum.map(results, & &1.likes_count)
      assert likes == [10, 15, 20]
    end

    # test "list_resources with invalid sort field returns unsorted results", %{posts: posts} do
    #   fields = TestResource.fields()

    #   options = %{
    #     "sort" => %{
    #       "sort_by" => "invalid_field",
    #       "sort_order" => "asc",
    #       "sortable?" => true
    #     }
    #   }

    #   results = TestResource.list_resources(fields, options)
    #   assert length(results) == 3

    #   assert Enum.map(results, & &1.id) |> Enum.sort() ==
    #            Enum.map(posts, & &1.id) |> Enum.sort()
    # end

    test "list_resources with non-sortable field returns unsorted results", %{posts: posts} do
      fields = TestResource.fields()

      options = %{
        "sort" => %{
          # repost_count is not sortable in sort_bys()
          "field" => "repost_count",
          "sort_order" => "asc",
          "sortable?" => true
        }
      }

      results = TestResource.list_resources(fields, options)
      assert length(results) == 3

      assert Enum.map(results, & &1.id) |> Enum.sort() ==
               Enum.map(posts, & &1.id) |> Enum.sort()
    end
  end
end
