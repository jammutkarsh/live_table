defmodule DemoWeb.Filters.RangeLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, schema: Demo.Weather.Record
  alias LiveTable.Range

  def fields do
    [
      location: %{
        label: "Location",
        sortable: true
      },
      temperature: %{
        label: "Temperature (°C)",
        sortable: true
      },
      humidity: %{
        label: "Humidity (%)",
        sortable: true
      },
      wind_speed: %{
        label: "Wind Speed (km/h)",
        sortable: true
      },
      precipitation: %{
        label: "Precipitation (mm)",
        sortable: true
      },
      weather_condition: %{
        label: "Condition",
        sortable: true
      },
      recorded_at: %{
        label: "Recorded At",
        sortable: true
      }
    ]
  end

  def filters do
    [
      temperature:
        Range.new(:temperature, "temp_range", %{
          type: :number,
          label: "Temperature Range",
          unit: "°C",
          min: 0,
          max: 40,
          step: 0.5
        }),
      humidity:
        Range.new(:humidity, "humidity_range", %{
          type: :number,
          label: "Humidity Range",
          unit: "%",
          min: 0,
          max: 100,
          step: 1
        }),
      wind_speed:
        Range.new(:wind_speed, "wind_range", %{
          type: :number,
          label: "Wind Speed Range",
          unit: "km/h",
          min: 0,
          max: 50,
          step: 0.5
        })
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-1">
        <h1 class="text-2xl font-semibold mb-4 dark:text-white">Range Filters Demo</h1>
        <p class="text-gray-600 mb-6">
          Demonstrates numeric range filter capabilities. Features:
          <ul class="list-disc list-inside mt-2">
            <li>Multiple concurrent range filters</li>
            <li>Different step sizes for different measures</li>
            <li>Unit display</li>
            <li>Real-time updates</li>
          </ul>
        </p>

        <.live_table fields={fields()} filters={filters()} options={@options} streams={@streams} />
      </div>
    </div>
    """
  end
end
