defmodule LiveTable.LiveResource do
  @moduledoc false
  alias LiveTable.{
    Filter,
    Join,
    Paginate,
    Sorting,
    Helpers,
    TableComponent,
    TableConfig
  }

  defmacro __using__(opts) do
    quote do
      import Ecto.Query
      import Sorting
      import Paginate
      import Join
      import Filter

      use Helpers,
        schema: unquote(opts[:schema]),
        table_options: TableConfig.get_table_options(table_options())

      use TableComponent, table_options: TableConfig.get_table_options(table_options())

      alias LiveTable.{Boolean, Select, Range}

      @resource_opts unquote(opts)
      @repo Application.compile_env(:live_table, :repo)

      def fields, do: []
      def filters, do: []

      def table_options(), do: %{}

      defoverridable fields: 0, filters: 0, table_options: 0

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

      def stream_resources(fields, %{"pagination" => %{"paginate?" => true}} = options) do
        per_page = options["pagination"]["per_page"] |> String.to_integer()

        list_resources(fields, options)
        |> @repo.all()
        |> Enum.split(per_page)
      end

      def stream_resources(fields, %{"pagination" => %{"paginate?" => false}} = options) do
        list_resources(fields, options) |> @repo.all()
      end

      def get_merged_table_options do
        TableConfig.get_table_options(table_options())
      end
    end
  end
end
