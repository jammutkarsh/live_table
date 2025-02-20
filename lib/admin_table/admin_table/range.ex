defmodule AdminTable.Range do
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

  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :number} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)

    dynamic(
      [{^table, t}],
      ^acc and fragment("? BETWEEN ? AND ?", field(t, ^field), ^min_value, ^max_value)
    )
  end

  def apply(acc, %__MODULE__{field: field, options: %{type: :number} = options})
      when is_atom(field) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)
    dynamic([p], ^acc and fragment("? BETWEEN ? AND ?", field(p, ^field), ^min_value, ^max_value))
  end

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

  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :datetime} = options}) do
    min_value = Map.get(options, :min, options.default_min)
    max_value = Map.get(options, :max, options.default_max)

    dynamic(
      [{^table, t}],
      ^acc and fragment("? BETWEEN ? AND ?", field(t, ^field), ^min_value, ^max_value)
    )
  end

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
