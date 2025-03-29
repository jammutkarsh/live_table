defmodule LiveTable.Range do
  @moduledoc """
  A module for handling range-based filters in LiveTable.

  This module provides functionality for creating and managing range filters that can handle
  numeric values, dates, and datetimes. It supports creating range sliders with customizable
  options and appearances.

  Makes use of nouislider under the hood for creating the range slider.
  See the [noUiSlider documentation](https://refreshless.com/nouislider/) for more details
  on customizing the slider behavior and appearance.

  > **Note**: Requires the TableHooks to be imported in your app.js

  ## Options
  The module accepts the following options:
  - `:type` - The type of range filter (`:number`, `:date`, or `:datetime`)
  - `:label` - The label text for the range filter
  - `:unit` - The unit to display after the label (optional)
  - `:css_classes` - CSS classes for the main container
  - `:slider_classes` - CSS classes for the slider element
  - `:label_classes` - CSS classes for the label element

  For default values, see: [LiveTable.Range source code](https://github.com/gurujada/live_table/blob/master/lib/live_table/range.ex)

  ## Types Support
  The module supports three types of range filters:
  - `:number` - For numeric ranges
  - `:date` - For date ranges
  - `:datetime` - For datetime ranges


  ### :number
  For numeric ranges with configurable min, max and step values:

  ```elixir
  Range.new(:price, "price_range", %{
    type: :number,
    label: "Price",
    default_min: 0,
    default_max: 1000,
    step: 10
  })
  # Renders a range filter with from 0 to 1000 with a step of 10.
  ```

  ### :date
  For date ranges with customizable date boundaries:

  ```elixir
  Range.new(:created_at, "date_range", %{
    type: :date,
    label: "Creation Date",
    default_min: ~D[2024-01-01],
    default_max: ~D[2024-12-31]
  })
  # Renders a date range filter with dates from 2024-01-01 to 2024-12-31.
  ```

  ### :datetime
  For datetime ranges with configurable datetime boundaries:

  ```elixir
  Range.new(:updated_at, "datetime_range", %{
    type: :datetime,
    label: "Last Updated",
    default_min: ~N[2024-01-01 00:00:00],
    default_max: ~N[2024-12-31 23:59:59],
    step: 3600 # Step in seconds
  })
  # Renders a datetime range filter with dates from 2024-01-01 00:00:00 to 2024-12-31 23:59:59.
  # Remember to pass the datetime values in `NaiveDateTime` format.
  ```

  ## Examples

  ```elixir
  # Creating a numeric range filter
  Range.new(:price, "price_range", %{
    type: :number,
    label: "Price Range",
    unit: "$",
    min: 0,
    max: 1000,
    step: 10
  })

  # Creating a date range filter
  Range.new(:created_at, "date_range", %{
    type: :date,
    label: "Date Range",
    min: ~D[2024-01-01],
    max: ~D[2024-12-31]
  })
  ```
  If you want to use the range filter with a joined schema, you can pass the field as a tuple, with the table name and the field-
  ```elixir
  Range.new({:suppliers, :created_at}, "created_at", %{
    type: :date,
    label: "Supplier Creation",
    min: ~D[2024-01-01],
    max: ~D[2024-12-31],
  })
  ```
  """

  import Ecto.Query
  use Phoenix.Component

  defstruct [:field, :key, :options]

  @type_defaults %{
    number: %{
      min: 0,
      max: 500,
      step: 1,
      default_min: 0,
      default_max: 500
    },
    date: %{
      min: ~D[2024-01-01],
      max: ~D[2024-12-31],
      step: 1,
      default_min: ~D[2024-01-01],
      default_max: ~D[2024-12-31]
    },
    datetime: %{
      min: ~N[2024-01-01 00:00:00],
      max: ~N[2024-12-31 23:59:59],
      step: 3600,
      default_min: ~N[2024-01-01 00:00:00],
      default_max: ~N[2024-12-31 23:59:59]
    }
  }

  @default_options %{
    type: :number,
    label: "Range",
    unit: "",
    css_classes: "w-64 mx-4",
    slider_classes: "w-64 h-2 mt-4",
    label_classes: "block text-sm font-medium mb-2 ark:text-neutral-200"
  }

  @doc false
  def new(field, key, options) do
    type = Map.get(options, :type, :number)
    type_defaults = Map.get(@type_defaults, type)

    complete_options =
      @default_options
      |> Map.merge(type_defaults || %{})
      |> Map.merge(options)
      |> Map.put(:type, type)

    %__MODULE__{field: field, key: key, options: complete_options}
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :number} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)

    dynamic(
      [{^table, t}],
      ^acc and fragment("? BETWEEN ? AND ?", field(t, ^field), ^min_value, ^max_value)
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: field, options: %{type: :number} = options})
      when is_atom(field) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)
    dynamic([p], ^acc and fragment("? BETWEEN ? AND ?", field(p, ^field), ^min_value, ^max_value))
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :date} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)

    dynamic(
      [{^table, t}],
      ^acc and
        fragment(
          "? BETWEEN ? AND ?",
          fragment("DATE(?)", field(t, ^field)),
          type(^min_value, :date),
          type(^max_value, :date)
        )
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: field, options: %{type: :date} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)

    dynamic(
      [p],
      ^acc and
        fragment(
          "? BETWEEN ? AND ?",
          fragment("DATE(?)", field(p, ^field)),
          type(^min_value, :date),
          type(^max_value, :date)
        )
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :datetime} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)

    dynamic(
      [{^table, t}],
      ^acc and fragment("? BETWEEN ? AND ?", field(t, ^field), ^min_value, ^max_value)
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: field, options: %{type: :datetime} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)
    dynamic([p], ^acc and fragment("? BETWEEN ? AND ?", field(p, ^field), ^min_value, ^max_value))
  end

  defp format_value(:number, value), do: value
  defp format_value(:date, value), do: Date.to_iso8601(value)

  defp format_value(:datetime, value) do
    value
    |> NaiveDateTime.to_iso8601()
    |> String.replace(" ", "T")
  end

  @doc false
  def render(assigns) do
    ~H"""
    <div class={@filter.options.css_classes}>
      <label class={@filter.options.label_classes}>
        {@filter.options.label}
        {if @filter.options.unit != "", do: " (#{@filter.options.unit})"}
      </label>
      <div
        id={"range_filter[#{@key}]"}
        phx-hook="RangeSlider"
        phx-update="ignore"
        data-key={@key}
        data-type={@filter.options.type}
        data-min={format_value(@filter.options.type, @filter.options.default_min)}
        data-max={format_value(@filter.options.type, @filter.options.default_max)}
        data-step={@filter.options.step}
        data-start={
          min = get_in(@filter.options, [:min]) || @filter.options.default_min
          max = get_in(@filter.options, [:max]) || @filter.options.default_max

          Jason.encode!([
            if(is_nil(min),
              do: format_value(@filter.options.type, @filter.options.default_min),
              else: format_value(@filter.options.type, min)
            ),
            if(is_nil(max),
              do: format_value(@filter.options.type, @filter.options.default_max),
              else: format_value(@filter.options.type, max)
            )
          ])
        }
        class={@filter.options.slider_classes}
      >
        <div class="slider-target"></div>
      </div>
    </div>
    """
  end
end
