defmodule LiveTable.RangeTest do
  use LiveTable.DataCase
  alias LiveTable.Range
  import Phoenix.LiveViewTest

  describe "new/3" do
    test "creates a range filter with default number type" do
      range = Range.new(:price, "price_range", %{})

      assert range.field == :price
      assert range.key == "price_range"
      assert range.options.type == :number
      assert range.options.label == "Range"
      assert range.options.min == 0
      assert range.options.max == 100
      assert range.options.step == 1
      assert range.options.default_min == 0
      assert range.options.default_max == 100
    end

    test "creates a range filter with custom number options" do
      options = %{
        type: :number,
        label: "Price Range",
        unit: "$",
        min: 10,
        max: 1000,
        step: 5,
        default_min: 50,
        default_max: 500
      }

      range = Range.new(:price, "price_range", options)

      assert range.options.type == :number
      assert range.options.label == "Price Range"
      assert range.options.unit == "$"
      assert range.options.min == 10
      assert range.options.max == 1000
      assert range.options.step == 5
      assert range.options.default_min == 50
      assert range.options.default_max == 500
    end

    test "creates a date range filter" do
      min_date = ~D[2024-01-01]
      max_date = ~D[2024-12-31]

      options = %{
        type: :date,
        label: "Date Range",
        min: min_date,
        max: max_date,
        default_min: min_date,
        default_max: max_date
      }

      range = Range.new(:created_at, "date_range", options)

      assert range.options.type == :date
      assert range.options.label == "Date Range"
      assert range.options.min == min_date
      assert range.options.max == max_date
      assert range.options.default_min == min_date
      assert range.options.default_max == max_date
    end

    test "creates a datetime range filter" do
      min_datetime = ~N[2024-01-01 00:00:00]
      max_datetime = ~N[2024-12-31 23:59:59]

      options = %{
        type: :datetime,
        label: "DateTime Range",
        min: DateTime.from_naive!(min_datetime, "Etc/UTC"),
        max: DateTime.from_naive!(max_datetime, "Etc/UTC"),
        default_min: DateTime.from_naive!(min_datetime, "Etc/UTC"),
        default_max: DateTime.from_naive!(max_datetime, "Etc/UTC"),
        step: 3600
      }

      range = Range.new(:updated_at, "datetime_range", options)

      assert range.options.type == :datetime
      assert range.options.label == "DateTime Range"
      assert range.options.step == 3600
    end

    test "creates a range filter with joined field" do
      options = %{
        type: :number,
        label: "Supplier Price"
      }

      range = Range.new({:suppliers, :price}, "supplier_price", options)

      assert range.field == {:suppliers, :price}
      assert range.key == "supplier_price"
    end

    test "preserves custom CSS classes" do
      options = %{
        css_classes: "custom-container",
        slider_classes: "custom-slider",
        label_classes: "custom-label"
      }

      range = Range.new(:value, "value_range", options)

      assert range.options.css_classes == "custom-container"
      assert range.options.slider_classes == "custom-slider"
      assert range.options.label_classes == "custom-label"
    end

    test "sets slider options correctly" do
      options = %{
        slider_options: %{
          tooltips: false,
          padding: 10,
          behaviour: "tap"
        }
      }

      range = Range.new(:value, "value_range", options)

      assert range.options.slider_options.tooltips == false
      assert range.options.slider_options.padding == 10
      assert range.options.slider_options.behaviour == "tap"
    end
  end

  describe "apply/2 for number type" do
    test "applies range filter for simple field" do
      range =
        Range.new(:price, "price_range", %{
          type: :number,
          current_min: 10,
          current_max: 100
        })

      acc = true
      dynamic = Range.apply(acc, range)

      # Create a query to test the dynamic
      query = from(p in "products", select: %{id: p.id, price: p.price}, where: ^dynamic)
      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert sql =~ "BETWEEN"
      assert params == [true, 10, 100]
    end

    test "applies range filter for joined field" do
      range =
        Range.new({:suppliers, :price}, "supplier_price", %{
          type: :number,
          current_min: 20,
          current_max: 200
        })

      acc = true
      dynamic = Range.apply(acc, range)

      # The dynamic should reference the suppliers table
      query =
        from(p in "products",
          join: s in "suppliers",
          as: :suppliers,
          on: p.supplier_id == s.id,
          select: %{id: p.id, supplier_price: s.price},
          where: ^dynamic
        )

      {sql, _params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert sql =~ "BETWEEN"
      # suppliers table alias
      assert sql =~ "s1"
    end

    test "uses default values when current values not set" do
      range =
        Range.new(:price, "price_range", %{
          type: :number,
          default_min: 5,
          default_max: 50
        })

      acc = true
      dynamic = Range.apply(acc, range)

      query = from(p in "products", select: %{id: p.id, price: p.price}, where: ^dynamic)
      {_sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert params == [true, 5, 50]
    end
  end

  describe "apply/2 for date type" do
    test "applies date range filter for simple field" do
      min_date = ~D[2024-01-01]
      max_date = ~D[2024-12-31]

      range =
        Range.new(:created_at, "date_range", %{
          type: :date,
          current_min: min_date,
          current_max: max_date
        })

      acc = true
      dynamic = Range.apply(acc, range)

      query =
        from(p in "products", select: %{id: p.id, created_at: p.created_at}, where: ^dynamic)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert sql =~ "DATE("
      assert sql =~ "BETWEEN"
      assert params == [true, min_date, max_date]
    end

    test "applies date range filter for joined field" do
      min_date = ~D[2024-01-01]
      max_date = ~D[2024-12-31]

      range =
        Range.new({:suppliers, :created_at}, "supplier_created", %{
          type: :date,
          current_min: min_date,
          current_max: max_date
        })

      acc = true
      dynamic = Range.apply(acc, range)

      query =
        from(p in "products",
          join: s in "suppliers",
          as: :suppliers,
          on: p.supplier_id == s.id,
          select: %{id: p.id, supplier_created: s.created_at},
          where: ^dynamic
        )

      {sql, _params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert sql =~ "DATE("
      assert sql =~ "BETWEEN"
    end
  end

  describe "apply/2 for datetime type" do
    test "applies datetime range filter for simple field" do
      min_datetime = ~N[2024-01-01 00:00:00]
      max_datetime = ~N[2024-12-31 23:59:59]

      range =
        Range.new(:updated_at, "datetime_range", %{
          type: :datetime,
          current_min: min_datetime,
          current_max: max_datetime
        })

      acc = true
      dynamic = Range.apply(acc, range)

      query =
        from(p in "products", select: %{id: p.id, updated_at: p.updated_at}, where: ^dynamic)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert sql =~ "BETWEEN"
      assert params == [true, min_datetime, max_datetime]
    end

    test "applies datetime range filter for joined field" do
      min_datetime = ~N[2024-01-01 00:00:00]
      max_datetime = ~N[2024-12-31 23:59:59]

      range =
        Range.new({:suppliers, :updated_at}, "supplier_updated", %{
          type: :datetime,
          current_min: min_datetime,
          current_max: max_datetime
        })

      acc = true
      dynamic = Range.apply(acc, range)

      query =
        from(p in "products",
          join: s in "suppliers",
          as: :suppliers,
          on: p.supplier_id == s.id,
          select: %{id: p.id, supplier_updated: s.updated_at},
          where: ^dynamic
        )

      {sql, _params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      assert sql =~ "BETWEEN"
    end
  end

  describe "render/1" do
    test "renders number range slider with default options" do
      range = Range.new(:price, "price_range", %{type: :number})

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "price_range",
          applied_filters: %{}
        })

      assert html =~ "Range"
      assert html =~ ~s(id="range_filter[price_range]")
      assert html =~ ~s(phx-hook="RangeSlider")
      assert html =~ ~s(data-type="number")
      assert html =~ ~s(data-min="0")
      assert html =~ ~s(data-max="100")
      assert html =~ ~s(data-step="1")
    end

    test "renders number range slider with unit" do
      range =
        Range.new(:price, "price_range", %{
          type: :number,
          label: "Price",
          unit: "$"
        })

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "price_range",
          applied_filters: %{}
        })

      assert html =~ "Price"
      assert html =~ "($)"
    end

    test "renders date range slider" do
      min_date = ~D[2024-01-01]
      max_date = ~D[2024-12-31]

      range =
        Range.new(:created_at, "date_range", %{
          type: :date,
          label: "Creation Date",
          min: min_date,
          max: max_date,
          default_min: min_date,
          default_max: max_date
        })

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "date_range",
          applied_filters: %{}
        })

      assert html =~ "Creation Date"
      assert html =~ ~s(data-type="date")
      assert html =~ ~s(data-min="2024-01-01")
      assert html =~ ~s(data-max="2024-12-31")
    end

    test "renders datetime range slider" do
      min_datetime = DateTime.from_naive!(~N[2024-01-01 00:00:00], "Etc/UTC")
      max_datetime = DateTime.from_naive!(~N[2024-12-31 23:59:59], "Etc/UTC")

      range =
        Range.new(:updated_at, "datetime_range", %{
          type: :datetime,
          label: "Last Updated",
          min: min_datetime,
          max: max_datetime,
          default_min: min_datetime,
          default_max: max_datetime
        })

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "datetime_range",
          applied_filters: %{}
        })

      assert html =~ "Last Updated"
      assert html =~ ~s(data-type="datetime")
      assert html =~ "2024-01-01T00:00:00"
      assert html =~ "2024-12-31T23:59:59"
    end

    test "renders with current values from applied filters" do
      range =
        Range.new(:price, "price_range", %{
          type: :number,
          current_min: 25,
          current_max: 75
        })

      applied_filters = %{
        "price_range" => %{
          options: %{current_min: 30, current_max: 70}
        }
      }

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "price_range",
          applied_filters: applied_filters
        })

      assert html =~ ~s(data-current-min="30")
      assert html =~ ~s(data-current-max="70")
    end

    test "renders with custom CSS classes" do
      range =
        Range.new(:value, "value_range", %{
          css_classes: "custom-container",
          slider_classes: "custom-slider",
          label_classes: "custom-label"
        })

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "value_range",
          applied_filters: %{}
        })

      assert html =~ ~s(class="custom-container")
      assert html =~ ~s(class="custom-slider")
      assert html =~ ~s(class="custom-label")
    end

    test "renders with pips configuration" do
      range =
        Range.new(:value, "value_range", %{
          pips: true,
          pips_mode: "positions",
          pips_values: [0, 50, 100],
          pips_density: 2,
          pips_stepped: false
        })

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "value_range",
          applied_filters: %{}
        })

      assert html =~ ~s(data-pips="true")
      assert html =~ ~s(data-pips-mode="positions")
      assert html =~ ~s(data-pips-values="[0,50,100]")
      assert html =~ ~s(data-pips-density="2")
      assert html =~ ~s(data-pips-stepped="false")
    end

    test "renders with event type configuration" do
      range =
        Range.new(:value, "value_range", %{
          event_type: "slide"
        })

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "value_range",
          applied_filters: %{}
        })

      assert html =~ ~s(data-event-type="slide")
    end
  end

  describe "edge cases and error handling" do
    test "handles nil current values gracefully" do
      range =
        Range.new(:price, "price_range", %{
          type: :number,
          current_min: nil,
          current_max: nil,
          default_min: 0,
          default_max: 100
        })

      acc = true
      dynamic = Range.apply(acc, range)

      query = from(p in "products", select: %{id: p.id, price: p.price}, where: ^dynamic)
      {_sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)

      # Should fall back to default values
      assert params == [true, 0, 100]
    end

    test "handles empty applied filters map" do
      range = Range.new(:price, "price_range", %{type: :number})

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "price_range",
          applied_filters: %{}
        })

      # Should render without errors
      assert html =~ ~s(id="range_filter[price_range]")
    end

    test "preserves phx-update='ignore' attribute" do
      range = Range.new(:price, "price_range", %{})

      html =
        render_component(&Range.render/1, %{
          filter: range,
          key: "price_range",
          applied_filters: %{}
        })

      assert html =~ ~s(phx-update="ignore")
    end

    test "deep merges options correctly" do
      options = %{
        slider_options: %{
          tooltips: false,
          new_option: "value"
        }
      }

      range = Range.new(:value, "value_range", options)

      # Should preserve default options not overridden
      assert range.options.slider_options.padding == 0
      assert range.options.slider_options.behaviour == "drag"
      # Should override specified options
      assert range.options.slider_options.tooltips == false
      # Should add new options
      assert range.options.slider_options.new_option == "value"
    end
  end
end
