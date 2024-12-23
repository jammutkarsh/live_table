defmodule TestWeb.LiveResource do
  alias AdminTable.Sorting

  defmacro __using__(opts) do
    quote do
      import Ecto.Query
      alias AdminTable.Repo
      alias AdminTable.Sorting
      import Sorting

      @resource_opts unquote(opts)

      def fields, do: []
      defoverridable fields: 0

      def list_resources(fields, options) do
        schema = @resource_opts[:schema]

        schema
        |> from(as: :resource)
        |> maybe_sort(options["sort"], options["sort"]["sortable?"])
        |> Repo.all()
      end
    end
  end
end
