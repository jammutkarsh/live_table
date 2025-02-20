defmodule AdminTableWeb.LiveResource do
  alias AdminTable.{
    Filter,
    Join,
    Paginate,
    Sorting,
    Helpers,
    LiveViewHelpers,
    TableComponent,
    Repo
  }

  defmacro __using__(opts) do
    quote do
      import LiveViewHelpers
      import TableComponent
      import Ecto.Query
      import Sorting
      import Paginate
      import Join
      import Filter
      use Helpers, resource: unquote(opts[:resource])

      @resource_opts unquote(opts)

      def fields, do: []
      def filters, do: []
      defoverridable fields: 0, filters: 0

      def list_resources(fields, options) do
        schema = @resource_opts[:schema]

        filters = Map.get(options, "filters", nil)

        schema
        |> from(as: :resource)
        |> join_associations(fields)
        |> select_columns(fields)
        |> apply_filters(filters, fields)
        |> maybe_sort(fields, options["sort"]["sort_params"], options["sort"]["sortable?"])
        |> maybe_paginate(options["pagination"], options["pagination"]["paginate?"])
      end

      def stream_resources(fields, query) do
        list_resources(fields, query) |> Repo.all()
      end
    end
  end
end
