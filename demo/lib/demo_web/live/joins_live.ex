defmodule DemoWeb.JoinsLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, schema: Demo.Events.Event

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
      # Registration count with status breakdown
      total_registrations: %{
        label: "Total Registrations",
        sortable: true,
        assoc: {:registrations, :status},
        computed: dynamic([resource: e, registrations: r], r.id)
      }
      # confirmed_count: %{
      #   label: "Confirmed",
      #   sortable: true,
      #   computed: dynamic([resource: e, registrations: r],
      #     count(fragment("CASE WHEN ? = 'confirmed' THEN 1 END", r.status)))
      # },
      # waitlist_count: %{
      #   label: "Waitlisted",
      #   sortable: true,
      #   computed: dynamic([resource: e, registrations: r],
      #     count(fragment("CASE WHEN ? = 'waitlisted' THEN 1 END", r.status)))
      # },
      # # Latest registration
      # latest_registration: %{
      #   label: "Latest Registration",
      #   sortable: true,
      #   computed: dynamic([resource: e, registrations: r],
      #     fragment("MAX(?)", r.inserted_at))
      # }
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 dark:bg-neutral-900">
      <div class="py-8">
        <h1 class="text-2xl font-semibold mb-4 dark:text-neutral-100">Table Joins Demo</h1>
        <p class="text-gray-600 dark:text-neutral-400 mb-6">
          Demonstrates different types of table joins and computed fields. Features:
          <ul class="list-disc list-inside mt-2 dark:text-neutral-300">
            <li>One-to-many join (Products → Categories)</li>
            <li>Many-to-many join (Products ↔ Suppliers)</li>
            <li>One-to-one join (Products → Image)</li>
            <li>Computed fields across joins</li>
            <li>Aggregations (supplier count)</li>
            <li>Complex computed fields (total value)</li>
          </ul>
        </p>

        <.live_table fields={fields()} filters={filters()} options={@options} streams={@streams} />
      </div>
    </div>
    """
  end
end
