defmodule LiveTable.RangeTest do
  use LiveTable.DataCase
  import Phoenix.LiveViewTest
  alias LiveTable.{Range, Repo, Catalog.Product, Catalog.Category, Catalog.Supplier, Catalog.Image}

  describe "Range.new/3" do
    test "creates struct with correct attributes" do
      field = :price
      key = "price-range"

      options = %{
        min: 0,
        max: 100,
        label: "Custom Range",
        unit: "€",
        css_classes: "custom-wrapper",
        slider_classes: "custom-slider",
        id_prefix: "custom"
      }

      result = Range.new(field, key, options)

      assert %Range{} = result
      assert result.field == field
      assert result.key == key
      assert result.options.min == 0
      assert result.options.max == 100
      assert result.options.label == "Custom Range"
      assert result.options.unit == "€"
      # Verify it merges with defaults
      assert result.options.step == 1
      assert result.options.default_min == 0
      assert result.options.default_max == 500
      assert result.options.css_classes == "custom-wrapper"
      assert result.options.slider_classes == "custom-slider"
      assert result.options.id_prefix == "custom"
    end

    test "accepts integer and float values" do
      integer_range = Range.new(:price, "int-range", %{min: 0, max: 100})
      float_range = Range.new(:price, "float-range", %{min: 0.0, max: 99.9})

      assert integer_range.options.min == 0
      assert integer_range.options.max == 100
      assert float_range.options.min == 0.0
      assert float_range.options.max == 99.9
    end

    test "creates a Range struct with default values" do
      result = Range.new(:price, "price-range", %{})

      assert %Range{} = result
      assert result.field == :price
      assert result.key == "price-range"
      assert result.options.min == 0
      assert result.options.max == 500
      assert result.options.step == 1
      assert result.options.type == :number
      assert result.options.label == "Range"
      assert result.options.unit == ""
    end
  end

  describe "Range.apply/2" do
    test "applies between condition to empty accumulator" do
      filter = Range.new(:price, "price-range", %{min: 10, max: 50})
      initial_dynamic = true

      result = Range.apply(initial_dynamic, filter)

      assert is_struct(result, Ecto.Query.DynamicExpr)
      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "where: ^true and fragment"
      assert inspect(query) =~ "BETWEEN"
    end

    test "combines with existing conditions" do
      filter = Range.new(:price, "price-range", %{min: 10, max: 50})
      initial_condition = dynamic([p], p.category_id == 1)

      result = Range.apply(initial_condition, filter)

      assert is_struct(result, Ecto.Query.DynamicExpr)
      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "where: p0.category_id == 1"
      assert inspect(query) =~ "BETWEEN"
    end
  end

  describe "Range.render/1" do
    test "renders range slider with correct attributes" do
      filter =
        Range.new(:price, "price-range", %{
          min: 10,
          max: 50,
          label: "Price Range",
          unit: "€",
          css_classes: "custom-wrapper",
          slider_classes: "custom-slider"
        })

      html =
        render_component(&Range.render/1, %{
          key: "price-range",
          filter: filter
        })

      assert html =~ ~s(phx-hook="RangeSlider")
      assert html =~ ~s(class="custom-wrapper")
      assert html =~ ~s(class="custom-slider")
      assert html =~ "Price Range"
      assert html =~ "(€)"
    end

    test "uses default values when no options provided" do
      filter = Range.new(:price, "price-range", %{})

      html =
        render_component(&Range.render/1, %{
          key: "price-range",
          filter: filter
        })

      assert html =~ ~s(data-start=\"[0,500]\")
      assert html =~ ~s(data-type=\"number\")

      assert html =~ "Range"
    end

    test "renders with custom min/max values" do
      filter = Range.new(:price, "price-range", %{min: 25, max: 75})

      html =
        render_component(&Range.render/1, %{
          key: "price-range",
          filter: filter
        })

      assert html =~ ~s(data-start=\"[25,75]\")
    end
  end

  describe "Range filters integration" do
    setup do
      {:ok, cheap} = %Product{name: "Cheap", price: 25} |> Repo.insert()
      {:ok, medium} = %Product{name: "Medium", price: 50} |> Repo.insert()
      {:ok, expensive} = %Product{name: "Expensive", price: 100} |> Repo.insert()

      %{products: [cheap, medium, expensive]}
    end

    test "filters products within range", %{products: [cheap, medium, expensive]} do
      filter = Range.new(:price, "price-range", %{min: 20, max: 60})

      query =
        Product
        |> where(^Range.apply(true, filter))
        |> Repo.all()

      result_ids = Enum.map(query, & &1.id)
      assert length(query) == 2
      assert cheap.id in result_ids
      assert medium.id in result_ids
      refute expensive.id in result_ids
    end

    test "combines with other filters", %{products: _products} do
      range_filter = Range.new(:price, "price-range", %{min: 0, max: 75})
      name_condition = dynamic([p], like(p.name, "%m%"))

      query =
        Product
        |> where(^name_condition)
        |> where(^Range.apply(true, range_filter))
        |> Repo.all()

      result_names = Enum.map(query, & &1.name)
      assert length(query) == 1
      assert "Medium" in result_names
    end
  end

  describe "Range filter error cases" do
    test "handles missing min/max options" do
      filter = Range.new(:price, "price-range", %{min: nil, max: nil})
      result = Range.apply(true, filter)

      assert is_struct(result, Ecto.Query.DynamicExpr)
    end

    test "handles swapped min/max dates" do
      filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          # Later date
          min: ~D[2024-12-31],
          # Earlier date
          max: ~D[2024-01-01]
        })

      result = Range.apply(true, filter)
      query = from(p in "products", where: ^result)

      # Should still construct a valid query even with swapped dates
      assert is_struct(result, Ecto.Query.DynamicExpr)
      assert inspect(query) =~ "DATE(?"
      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "2024-12-31"
      assert inspect(query) =~ "2024-01-01"
    end

    test "handles special characters in keys and units" do
      filter =
        Range.new(:price, "price$range", %{
          min: 0,
          max: 100,
          unit: "€/m²",
          label: "Area Cost"
        })

      html =
        render_component(&Range.render/1, %{
          key: "price$range",
          filter: filter
        })

      assert html =~ ~s(data-key="price$range")
      assert html =~ "Area Cost"
      assert html =~ "(€/m²)"
    end

    test "works with zero values" do
      filter = Range.new(:price, "zero-range", %{min: 0, max: 0})
      result = Range.apply(true, filter)

      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "0"
    end
  end

  describe "Range filter custom styling" do
    test "supports custom styling" do
      filter =
        Range.new(:price, "price-range", %{
          label_classes: "custom-label-class dark:text-white"
        })

      html =
        render_component(&Range.render/1, %{
          key: "price-range",
          filter: filter
        })

      assert html =~ "custom-label-class"
      assert html =~ "dark:text-white"
    end

    test "supports custom slider appearance" do
      filter =
        Range.new(:price, "price-range", %{
          slider_classes: "h-4 rounded-full bg-blue-200"
        })

      html =
        render_component(&Range.render/1, %{
          key: "price-range",
          filter: filter
        })

      # Check individual classes
      assert html =~ "h-4"
      assert html =~ "rounded-full"
      assert html =~ "bg-blue-200"
    end
  end

  describe "Range filter boundary cases" do
    test "handles extremely large numbers" do
      filter = Range.new(:price, "large-range", %{min: 999_999_999, max: 9_999_999_999})
      result = Range.apply(true, filter)

      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "999_999_999"
    end

    test "handles negative numbers" do
      filter = Range.new(:price, "negative-range", %{min: -100, max: -50})
      result = Range.apply(true, filter)

      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "-100"
      assert inspect(query) =~ "-50"
    end
  end

  describe "Range filter with dates" do
    test "creates date range filter" do
      filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          min: ~D[2024-01-01],
          max: ~D[2024-12-31]
        })

      assert filter.options.type == :date
      assert filter.options.min == ~D[2024-01-01]
      assert filter.options.max == ~D[2024-12-31]
      # 1 day step
      assert filter.options.step == 1
    end

    test "applies date range filter" do
      filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          min: ~D[2024-01-01],
          max: ~D[2024-12-31]
        })

      result = Range.apply(true, filter)
      query = from(p in "products", where: ^result)

      assert inspect(query) =~ "DATE(?"
      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "2024-01-01"
      assert inspect(query) =~ "2024-12-31"
    end

    test "renders date range component" do
      filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          min: ~D[2024-01-01],
          max: ~D[2024-12-31],
          label: "Publication Date"
        })

      html =
        render_component(&Range.render/1, %{
          key: "date-range",
          filter: filter
        })

      assert html =~ ~s(data-type="date")
      assert html =~ "2024-01-01"
      assert html =~ "2024-12-31"
      assert html =~ "Publication Date"
    end
  end

  describe "Range filter empty states" do
    test "handles nil values in date ranges" do
      filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          min: nil,
          max: ~D[2024-12-31]
        })

      result = Range.apply(true, filter)
      assert is_struct(result, Ecto.Query.DynamicExpr)

      query = from(p in "products", where: ^result)
      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "2024-12-31"
    end
  end

  describe "Range type defaults" do
    test "applies correct type defaults" do
      date_filter = Range.new(:published_at, "date-range", %{type: :date})
      datetime_filter = Range.new(:created_at, "datetime-range", %{type: :datetime})
      number_filter = Range.new(:price, "price-range", %{type: :number})

      # 1 day
      assert date_filter.options.step == 1
      # 1 hour in seconds
      assert datetime_filter.options.step == 3600
      assert number_filter.options.step == 1

      assert %Date{} = date_filter.options.default_min
      assert %Date{} = date_filter.options.default_max
      assert %NaiveDateTime{} = datetime_filter.options.default_min
      assert %NaiveDateTime{} = datetime_filter.options.default_max
      assert is_number(number_filter.options.default_min)
      assert is_number(number_filter.options.default_max)
    end
  end

  #########

  describe "Range value formatting" do
    test "correctly formats values based on type" do
      date_filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          min: ~D[2024-01-01],
          max: ~D[2024-12-31]
        })

      datetime_filter =
        Range.new(:created_at, "datetime-range", %{
          type: :datetime,
          min: ~N[2024-01-01 00:00:00],
          max: ~N[2024-12-31 23:59:59]
        })

      date_html =
        render_component(&Range.render/1, %{
          key: "date-range",
          filters: %{"date-range" => date_filter},
          filter: date_filter
        })

      datetime_html =
        render_component(&Range.render/1, %{
          key: "datetime-range",
          filters: %{"datetime-range" => datetime_filter},
          filter: datetime_filter
        })

      # Check date formatting
      assert date_html =~ "2024-01-01"
      # Should not include time part for date type
      refute date_html =~ "2024-01-01T"

      # Check datetime formatting
      assert datetime_html =~ "2024-01-01T00:00:00"
      assert datetime_html =~ "2024-12-31T23:59:59"
    end
  end

  describe "Range filter with datetime" do
    test "creates datetime range filter" do
      filter =
        Range.new(:created_at, "datetime-range", %{
          type: :datetime,
          min: ~N[2024-01-01 00:00:00],
          max: ~N[2024-12-31 23:59:59]
        })

      assert filter.options.type == :datetime
      assert filter.options.min == ~N[2024-01-01 00:00:00]
      assert filter.options.max == ~N[2024-12-31 23:59:59]
      # 1 hour step
      assert filter.options.step == 3600
    end

    test "applies datetime range filter" do
      filter =
        Range.new(:created_at, "datetime-range", %{
          type: :datetime,
          min: ~N[2024-01-01 00:00:00],
          max: ~N[2024-12-31 23:59:59]
        })

      result = Range.apply(true, filter)
      query = from(p in "products", where: ^result)

      assert inspect(query) =~ "BETWEEN"
      assert inspect(query) =~ "2024-01-01 00:00:00"
      assert inspect(query) =~ "2024-12-31 23:59:59"
    end

    test "renders datetime range component" do
      filter =
        Range.new(:created_at, "datetime-range", %{
          type: :datetime,
          min: ~N[2024-01-01 00:00:00],
          max: ~N[2024-12-31 23:59:59],
          label: "Creation Time"
        })

      html =
        render_component(&Range.render/1, %{
          key: "datetime-range",
          filter: filter
        })

      assert html =~ ~s(data-type="datetime")
      assert html =~ "2024-01-01T00:00:00"
      assert html =~ "2024-12-31T23:59:59"
      assert html =~ "Creation Time"
    end
  end

  describe "Range filter formatting edge cases" do
    test "handles timezone formatting in dates" do
      datetime = ~N[2024-01-01 23:59:59]

      filter =
        Range.new(:created_at, "datetime-range", %{
          type: :datetime,
          min: datetime,
          max: datetime
        })

      html =
        render_component(&Range.render/1, %{
          key: "datetime-range",
          filters: %{"datetime-range" => filter},
          filter: filter
        })

      assert html =~ "2024-01-01T23:59:59"
    end

    test "formats dates with leading zeros" do
      date = ~D[2024-09-09]

      filter =
        Range.new(:published_at, "date-range", %{
          type: :date,
          min: date,
          max: date
        })

      html =
        render_component(&Range.render/1, %{
          key: "date-range",
          filters: %{"date-range" => filter},
          filter: filter
        })

      # Ensures months and days below 10 are properly zero-padded
      assert html =~ "2024-09-09"
    end
  end

  describe "Range filter integration with joined schemas" do
     setup do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      yesterday = DateTime.add(now, -24 * 60 * 60)
      tomorrow = DateTime.add(now, 24 * 60 * 60)

      # Create categories with different timestamps
      {:ok, old_category} =
        %Category{
          name: "Old Category",
          description: "Created yesterday",
          inserted_at: yesterday
        }
        |> Repo.insert()

      {:ok, current_category} =
        %Category{
          name: "Current Category",
          description: "Created today",
          inserted_at: now
        }
        |> Repo.insert()

      {:ok, future_category} =
        %Category{
          name: "Future Category",
          description: "Created tomorrow",
          inserted_at: tomorrow
        }
        |> Repo.insert()

      # Create suppliers with stock levels in their descriptions
      {:ok, supplier_1} =
        %Supplier{
          name: "Supplier One",
          contact_info: "supplier1@example.com",
          address: "Stock level: High"
        }
        |> Repo.insert()

      {:ok, supplier_2} =
        %Supplier{
          name: "Supplier Two",
          contact_info: "supplier2@example.com",
          address: "Stock level: Low"
        }
        |> Repo.insert()

      # Create images
      {:ok, image_1} =
        %Image{
          url: "https://example.com/image1.jpg"
        }
        |> Repo.insert()

      {:ok, image_2} =
        %Image{
          url: "https://example.com/image2.jpg"
        }
        |> Repo.insert()

      # Products with all associations
      {:ok, cheap_old} =
        %Product{
          name: "Cheap Old",
          description: "Old cheap product",
          price: 10,
          stock_quantity: 5,
          category_id: old_category.id
        }
        |> Repo.insert()

      {:ok, mid_current} =
        %Product{
          name: "Mid Current",
          description: "Current mid-range product",
          price: 50,
          stock_quantity: 3,
          category_id: current_category.id
        }
        |> Repo.insert()

      {:ok, expensive_future} =
        %Product{
          name: "Expensive Future",
          description: "Future expensive product",
          price: 100,
          stock_quantity: 1,
          category_id: future_category.id
        }
        |> Repo.insert()

      # Product with no associations for edge case testing
      {:ok, orphan_product} =
        %Product{
          name: "Orphan Product",
          description: "No associations",
          price: 75,
          stock_quantity: 0
        }
        |> Repo.insert()

      # Set up many-to-many relationships with timestamps
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      Repo.insert_all("products_suppliers", [
        %{
          product_id: cheap_old.id,
          supplier_id: supplier_1.id,
          inserted_at: timestamp,
          updated_at: timestamp
        },
        %{
          product_id: mid_current.id,
          supplier_id: supplier_1.id,
          inserted_at: timestamp,
          updated_at: timestamp
        },
        %{
          product_id: expensive_future.id,
          supplier_id: supplier_2.id,
          inserted_at: timestamp,
          updated_at: timestamp
        }
      ])

      %{
        categories: [old_category, current_category, future_category],
        suppliers: [supplier_1, supplier_2],
        images: [image_1, image_2],
        products: [cheap_old, mid_current, expensive_future, orphan_product],
        dates: %{today: now, yesterday: yesterday, tomorrow: tomorrow}
      }
    end

    test "filters by base schema field (price)", %{products: [cheap, mid, expensive, _orphan]} do
      filter = Range.new(:price, "price-range", %{min: 20, max: 75})

      query =
        Product
        |> join(:inner, [p], c in assoc(p, :category))
        |> where(^Range.apply(true, filter))
        |> Repo.all()

      result_ids = Enum.map(query, & &1.id)
      assert length(query) == 1
      assert mid.id in result_ids
      refute cheap.id in result_ids
      refute expensive.id in result_ids
    end

    test "filters by joined schema field (category inserted_at)", %{
      products: [old, current, future, _orphan],
      dates: dates
    } do
      filter =
        Range.new({:category, :inserted_at}, "date-range", %{
          type: :datetime,
          min: dates.yesterday,
          max: dates.today
        })

      query =
        Product
        |> join(:inner, [p], category in assoc(p, :category), as: :category)
        |> where(^Range.apply(true, filter))
        |> Repo.all()

      result_ids = Enum.map(query, & &1.id)
      assert length(query) == 2
      assert old.id in result_ids
      assert current.id in result_ids
      refute future.id in result_ids
    end

    test "filters by joined schema using multiple price ranges" do
      category_products_filter = Range.new(:price, "category-products-price", %{min: 0, max: 30})
      direct_products_filter = Range.new(:price, "direct-price", %{min: 40, max: 60})

      query =
        Product
        |> join(:inner, [p], c in assoc(p, :category))
        |> join(:inner, [p, _c], s in assoc(p, :suppliers))
        |> where(^Range.apply(true, category_products_filter))
        |> or_where(^Range.apply(true, direct_products_filter))
        |> distinct(true)
        |> Repo.all()

      prices = Enum.map(query, & &1.price) |> Enum.map(&Decimal.to_float/1)

      # Should include products with price <= 30 OR price between 40-60
      assert Enum.any?(prices, &(&1 <= 30))
      assert Enum.any?(prices, &(&1 >= 40 and &1 <= 60))
      refute Enum.any?(prices, &(&1 > 60))
      refute Enum.any?(prices, &(&1 > 30 and &1 < 40))
    end

    test "handles null associations", %{products: [_cheap, _mid, _expensive, orphan]} do
      filter =
        Range.new(:price, "price-range", %{
          min: 70,
          max: 80
        })

      query =
        Product
        |> join(:left, [p], c in assoc(p, :category))
        |> where(^Range.apply(true, filter))
        |> Repo.all()

      # The orphan product should be included since we're using left join
      # and it has price = 75 which is within range 70-80
      assert orphan.id in Enum.map(query, & &1.id)
    end

    test "combines range filters across all associations", %{
      products: products,
      dates: dates
    } do
      category_filter =
        Range.new({:category, :inserted_at}, "category-date-range", %{
          type: :datetime,
          min: dates.yesterday,
          max: dates.today
        })

      price_filter = Range.new(:price, "price-range", %{min: 40, max: 60})
      stock_filter = Range.new(:stock_quantity, "stock-range", %{min: 2, max: 4})

      query =
        Product
        |> join(:inner, [p], category in assoc(p, :category), as: :category)
        |> join(:inner, [p, _c], s in assoc(p, :suppliers))
        |> where(^Range.apply(true, category_filter))
        |> where(^Range.apply(true, price_filter))
        |> where(^Range.apply(true, stock_filter))
        |> Repo.all()

      result = List.first(query)

      # Should match only the mid_current product which:
      # 1. Has price between 40-60
      # 2. Has stock between 2-4
      # 3. Is in a category created between yesterday and today
      assert result.price == Decimal.new("50")
      assert result.stock_quantity == 3
      assert result.id == Enum.find(products, &(&1.name == "Mid Current")).id
    end
  end
end
