ExUnit.start()

Application.ensure_all_started(:live_table)
Ecto.Adapters.SQL.Sandbox.mode(LiveTable.Repo, :manual)
