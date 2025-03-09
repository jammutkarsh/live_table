defmodule LiveTable.BooleanTest do
  use LiveTable.DataCase
  import Phoenix.LiveViewTest
  alias LiveTable.{Boolean, Repo, Catalog.Product}
  use LiveTable.FilterHelpers
  
  def filters(), do: []
  
  describe "Boolean.new/3" do
    test "creates struct with correct attributes" do
      field = :price
      key = "under-100"
      options = %{label: "Less than 100", condition: dynamic([p], p.price < 100)}

      result = Boolean.new(field, key, options)

      assert %Boolean{} = result
      assert result.field == field
      assert result.key == key
      assert result.options == options
    end
  end

  describe "Boolean.apply/2" do
    test "applies dynamic condition to empty accumulator" do
      filter = Boolean.new(:price, "under-100", %{condition: dynamic([p], p.price < 100)})
      initial_dynamic = true

      result = Boolean.apply(initial_dynamic, filter)

      assert is_struct(result, Ecto.Query.DynamicExpr)
      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "where: ^true and p0.price < 100"
    end

    test "combines with existing conditions" do
      filter = Boolean.new(:price, "under-100", %{condition: dynamic([p], p.price < 100)})
      initial_condition = dynamic([p], p.category_id == 1)

      result = Boolean.apply(initial_condition, filter)

      assert is_struct(result, Ecto.Query.DynamicExpr)
      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "where: p0.category_id == 1 and p0.price < 100"
    end
  end

  describe "Boolean.render/1" do
    test "renders checkbox with correct attributes" do
      filter =
        Boolean.new(:price, "under-100", %{
          label: "Less than 100",
          condition: dynamic([p], p.price < 100)
        })

      key = "under-100"
      filters = %{}

      html =
        render_component(&Boolean.render/1, %{
          filter: filter,
          key: key,
          applied_filters: filters
        })

      assert html =~ ~s(type="checkbox")
      assert html =~ ~s(name="filters[under-100]")
      assert html =~ "Less than 100"
      refute html =~ ~s(checked)
    end

    test "renders checkbox as checked when filter is active" do
      filter =
        Boolean.new(:price, "under-100", %{
          label: "Less than 100",
          condition: dynamic([p], p.price < 100)
        })

      key = "under-100"
      applied_filters = %{"under-100" => true}

      html =
        render_component(&Boolean.render/1, %{
          filter: filter,
          key: key,
          applied_filters: applied_filters
        })

      assert html =~ ~s(type="checkbox")
      assert html =~ ~s(name="filters[under-100]")
      assert html =~ ~s(checked)
    end
  end

  describe "Boolean filters integration" do
    setup do
      # Insert test data
      {:ok, cheap_product} =
        %Product{name: "Cheap Part", price: 50}
        |> Repo.insert()

      {:ok, expensive_product} =
        %Product{name: "Expensive Part", price: 150}
        |> Repo.insert()

      %{cheap_product: cheap_product, expensive_product: expensive_product}
    end

    test "filters products by price condition", %{
      cheap_product: cheap_product
    } do
      filter = Boolean.new(:price, "under-100", %{condition: dynamic([p], p.price < 100)})

      query =
        Product
        |> where(^Boolean.apply(true, filter))
        |> Repo.all()

      assert length(query) == 1
      assert hd(query).id == cheap_product.id
    end

    test "combines multiple boolean filters" do
      filter1 = Boolean.new(:price, "under-100", %{condition: dynamic([p], p.price < 100)})
      filter2 = Boolean.new(:name, "has-part", %{condition: dynamic([p], like(p.name, "%Part%"))})

      combined_condition =
        true
        |> Boolean.apply(filter1)
        |> Boolean.apply(filter2)

      query =
        Product
        |> where(^combined_condition)
        |> Repo.all()

      assert length(query) == 1
      assert hd(query).name == "Cheap Part"
      assert Decimal.equal?(hd(query).price, Decimal.new("50"))
    end
  end

  describe "Boolean filter error cases" do
    test "nil condition doesn't affect query results" do
      filter = Boolean.new(:price, "invalid", %{condition: nil})
      initial_condition = dynamic([p], p.price > 0)
      result = Boolean.apply(initial_condition, filter)

      # Convert to query to verify the condition remains unchanged
      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "where: p0.price > 0 and ^nil"
    end

    test "handles special characters in keys" do
      filter =
        Boolean.new(:price, "under$100", %{
          label: "Less than 100",
          condition: dynamic([p], p.price < 100)
        })

      html =
        render_component(&Boolean.render/1, %{
          filter: filter,
          key: "under$100",
          applied_filters: %{}
        })

      assert html =~ ~s(name="filters[under$100]")
    end

    test "requires condition in options" do
      assert_raise FunctionClauseError, fn ->
        filter = Boolean.new(:price, "test", %{})
        Boolean.apply(true, filter)
      end
    end

    test "works with empty options label" do
      filter = Boolean.new(:price, "test", %{label: "", condition: dynamic([p], p.price < 100)})

      html =
        render_component(&Boolean.render/1, %{
          filter: filter,
          key: "test",
          applied_filters: %{}
        })

      # Label text between label tag should be empty
      assert html =~ "<label"
      assert html =~ "</label>"
      refute html =~ ~s(</label>\n    something)
    end
  end

  describe "Boolean filter URL integration" do
    test "encodes filter in URL format" do
      filter =
        Boolean.new(:price, "under-100", %{
          label: "Less than 100",
          condition: dynamic([p], p.price < 100)
        })

      filters = %{price: filter}
      encoded = encode_filters(filters)

      assert encoded == %{"price" => "under-100"}
    end

    test "encodes multiple filters" do
      filter1 =
        Boolean.new(:price, "under-100", %{
          label: "Less than 100",
          condition: dynamic([p], p.price < 100)
        })

      filter2 =
        Boolean.new(:category, "electronics", %{
          label: "Electronics",
          condition: dynamic([p], p.category_id == 1)
        })

      filters = %{price: filter1, category: filter2}
      encoded = encode_filters(filters)

      assert encoded == %{
               "price" => "under-100",
               "category" => "electronics"
             }
    end
  end
end
