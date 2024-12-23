defmodule AdminTable.Repo do
  use Ecto.Repo,
    otp_app: :admin_table,
    adapter: Ecto.Adapters.Postgres
end
