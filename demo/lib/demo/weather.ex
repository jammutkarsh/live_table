defmodule Demo.Weather do
  import Ecto.Query
  alias Demo.Repo
  alias Demo.Weather.Record

  def list_weather_records do
    Record
    |> Repo.all()
  end

  def create_weather_record(attrs \\ %{}) do
    %Record{}
    |> Record.changeset(attrs)
    |> Repo.insert()
  end
end
