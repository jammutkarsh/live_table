defmodule Demo.Catalog do
  import Ecto.Query

  alias Demo.{Repo, Catalog.Supplier}

  def search_suppliers(text) do
    Supplier
    |> where([c], ilike(c.name, ^"%#{text}%"))
    |> select([c], {c.name, [c.id, c.contact_info]})
    |> Repo.all()
  end

end