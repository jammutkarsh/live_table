ExUnit.start()
{:ok, _} = LiveTable.Repo.start_link()

Ecto.Adapters.SQL.Sandbox.mode(LiveTable.Repo, :manual)
