defmodule AdminTableWeb.LiveResource do
  alias AdminTable.Filter
  alias AdminTable.Join
  alias AdminTable.Paginate
  alias AdminTable.Sorting

  defmacro __using__(opts) do
    quote do
      import Ecto.Query
      alias AdminTable.Repo
      alias AdminTable.Sorting
      import Sorting
      import Paginate
      import Join
      import Filter

      @resource_opts unquote(opts)

      def fields, do: []
      defoverridable fields: 0

      def list_resources(fields, options) do
        schema = @resource_opts[:schema]

        filters = Map.get(options, "filters", nil)

        schema
        |> from(as: :resource)
        |> join_associations(fields)
        |> select_columns(fields)
        |> apply_filters(filters, fields)
        # |> apply_text_search(options["filters"]["search"], fields)
        |> maybe_sort(fields, options["sort"]["sort_params"], options["sort"]["sortable?"])
        |> maybe_paginate(options["pagination"], options["pagination"]["paginate?"])
        |> Repo.all()
      end
    end
  end
end
