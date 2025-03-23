defmodule DemoWeb.JoinsLive do
  use DemoWeb, :live_view
  use LiveTable.LiveResource, resource: "joinslive", schema: Demo.Events.Event

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
        computed: dynamic([resource: e, registrations: r], count(r.id))
      },
      confirmed_count: %{
        label: "Confirmed",
        sortable: true,
        computed: dynamic([resource: e, registrations: r],
          count(fragment("CASE WHEN ? = 'confirmed' THEN 1 END", r.status)))
      },
      waitlist_count: %{
        label: "Waitlisted",
        sortable: true,
        computed: dynamic([resource: e, registrations: r],
          count(fragment("CASE WHEN ? = 'waitlisted' THEN 1 END", r.status)))
      },
      # Latest registration
      latest_registration: %{
        label: "Latest Registration",
        sortable: true,
        computed: dynamic([resource: e, registrations: r],
          fragment("MAX(?)", r.inserted_at))
      }
    ]
  end

end
