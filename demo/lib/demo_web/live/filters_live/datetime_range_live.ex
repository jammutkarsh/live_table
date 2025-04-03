defmodule DemoWeb.Filters.DateRangeLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, schema: Demo.Events.Event
  alias LiveTable.Range

  def fields do
    [
      title: %{
        label: "Event Title",
        sortable: true
      },
      starts_at: %{
        label: "Start Time",
        sortable: true
      },
      registration_deadline: %{
        label: "Registration Deadline",
        sortable: true
      },
      status: %{
        label: "Status",
        sortable: true
      },
      max_participants: %{
        label: "Capacity",
        sortable: true
      }
    ]
  end

  def filters do
    now = DateTime.utc_now()
    today = Date.utc_today()

    [
      # DateTime range filter
      event_time:
        Range.new(:starts_at, "event_time", %{
          type: :datetime,
          label: "Event Time Range",
          default_min: DateTime.add(now, -30, :day),
          default_max: DateTime.add(now, 30, :day),
          # 1 hour in seconds
          step: 3600
        }),

      # Date range filter
      deadline:
        Range.new(:registration_deadline, "deadline", %{
          type: :date,
          label: "Registration Deadline Range",
          default_min: Date.add(today, -7),
          default_max: Date.add(today, 30)
        })
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-8">
        <h1 class="text-2xl font-semibold mb-4 dark:text-white">
          Date & DateTime Range Filters Demo
        </h1>
        <p class="text-gray-600 mb-6">
          Demonstrates both date and datetime range filter capabilities. Features:
          <ul class="list-disc list-inside mt-2">
            <li>Pure date selection (Registration Deadline)</li>
            <li>Date and time selection (Event Time)</li>
            <li>Different granularity levels</li>
            <li>Independent date and datetime filters</li>
          </ul>
        </p>

        <.live_table fields={fields()} filters={filters()} options={@options} streams={@streams} />
      </div>
    </div>
    """
  end
end
