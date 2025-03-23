defmodule Demo.Catalog do
  import Ecto.Query

  alias Demo.{Repo, Catalog.Supplier, Catalog.Category}

  def search_suppliers(text) do
    Supplier
    |> where([c], ilike(c.name, ^"%#{text}%"))
    |> select([c], {c.name, [c.id, c.contact_info]})
    |> Repo.all()
  end

  def search_categories(text) do
    Category
    |> where([c], ilike(c.name, ^"%#{text}%"))
    |> select([c], {c.name, [c.id, c.description]})
    |> Repo.all()
  end
end
