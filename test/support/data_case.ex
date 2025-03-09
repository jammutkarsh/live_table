defmodule LiveTable.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias LiveTable.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import LiveTable.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(LiveTable.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(LiveTable.Repo, {:shared, self()})
    end

    :ok
  end
end
