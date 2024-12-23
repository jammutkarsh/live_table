defmodule AdminTable.SortingTest do
  use ExUnit.Case
  import Ecto.Query
  alias AdminTable.Sorting

  describe "maybe_sort/3" do
    test "returns original query when sorting is disabled" do
      query = from(u in "users")
      sort_params = %{"sort_by" => "name", "sort_order" => "asc"}

      result = Sorting.maybe_sort(query, sort_params, false)
      assert result == query
    end

    test "applies sorting when enabled" do
      query = from(u in "users")
      sort_params = %{"sort_by" => "name", "sort_order" => "asc"}

      result = Sorting.maybe_sort(query, sort_params, true)
      assert %Ecto.Query{} = result
      assert result != query
    end
  end

  setup do
    # Pre-create atoms that will be used in tests
    :body |> to_string() |> String.to_existing_atom()
    :likes_count |> to_string() |> String.to_existing_atom()
    :repost_count |> to_string() |> String.to_existing_atom()
    :photo_locations |> to_string() |> String.to_existing_atom()
    
    :ok
  end

  describe "sort/2" do
    test "handles ascending sort" do
      query = from(p in "posts")
      sort_params = [%{"sort_by" => "body", "sort_order" => "asc"}]

      result = Sorting.sort(query, sort_params)

      assert %Ecto.Query{} = result
      assert inspect(result) =~ "order_by: [asc: p0.body]"
    end

    test "handles descending sort" do
      query = from(p in "posts")
      sort_params = [%{"sort_by" => "likes_count", "sort_order" => "desc"}]

      result = Sorting.sort(query, sort_params)

      assert %Ecto.Query{} = result
      assert inspect(result) =~ "order_by: [desc: p0.likes_count]"
    end

    test "defaults to ascending inserted_at for invalid params" do
      query = from(p in "posts")
      sort_params = [%{"invalid" => "params"}]

      result = Sorting.sort(query, sort_params)

      assert %Ecto.Query{} = result
      assert inspect(result) =~ "order_by: [asc: p0.inserted_at]"
    end

    test "handles multiple sort parameters" do
      query = from(p in "posts")

      sort_params = [
        %{"sort_by" => "likes_count", "sort_order" => "desc"},
        %{"sort_by" => "repost_count", "sort_order" => "asc"}
      ]

      result = Sorting.sort(query, sort_params)

      assert %Ecto.Query{} = result
      assert inspect(result) =~ "order_by: [desc: p0.likes_count, asc: p0.repost_count]"
    end
  end

end
