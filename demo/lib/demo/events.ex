defmodule Demo.Events do
  import Ecto.Query
  alias Demo.Repo
  alias Demo.Events.{Event, Registration}

  def list_events do
    Event
    |> Repo.all()
  end

  def get_event!(id), do: Repo.get!(Event, id)

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def list_registrations(event_id) do
    Registration
    |> where([r], r.event_id == ^event_id)
    |> Repo.all()
  end

  def create_registration(attrs \\ %{}) do
    %Registration{}
    |> Registration.changeset(attrs)
    |> Repo.insert()
  end
end
