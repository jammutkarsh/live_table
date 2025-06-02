defmodule LiveTable.TableComponent do
  @moduledoc false
  defmacro __using__(opts) do
    quote do
      use Phoenix.Component
      import LiveTable.SortHelpers

      def live_table(var!(assigns)) do
        var!(assigns) = assign(var!(assigns), :table_options, unquote(opts)[:table_options])

        ~H"""
        <div class="flex flex-col dark:bg-neutral-800" id="live-table" phx-hook="Download">
          <.render_header {assigns} />
          <.render_content {assigns} />
          <.footer_section options={@options} />
        </div>
        """
      end

      defp render_header(%{table_options: %{custom_header: {module, function}}} = assigns) do
        # Call custom header component
        apply(module, function, [assigns])
      end

      defp render_header(var!(assigns)) do
        ~H"""
        <.header_section
          fields={@fields}
          filters={@filters}
          options={@options}
          table_options={@table_options}
        />
        """
      end

      defp header_section(%{table_options: %{mode: :table}} = var!(assigns)) do
        ~H"""
        <div class="-m-1.5 overflow-x-auto">
          <div class="p-1.5 min-w-full inline-block align-middle">
            <div class="border border-gray-300 divide-y divide-gray-300 rounded-lg dark:border-neutral-700 dark:divide-neutral-700">
              <.common_controls
                fields={@fields}
                filters={@filters}
                options={@options}
                table_options={@table_options}
              />
            </div>
          </div>
        </div>
        """
      end

      defp header_section(%{table_options: %{mode: :card}} = var!(assigns)) do
        ~H"""
        <div class="-m-1.5 overflow-x-auto">
          <div class="p-1.5 min-w-full inline-block align-middle">
            <div class="border border-gray-300 divide-y divide-gray-300 rounded-lg dark:border-neutral-700 dark:divide-neutral-700">
              <.common_controls
                fields={@fields}
                filters={@filters}
                options={@options}
                table_options={@table_options}
              />
            </div>
          </div>
        </div>
        """
      end

      defp common_controls(var!(assigns)) do
        ~H"""
        <.form for={%{}} phx-debounce={get_in(@table_options, [:search, :debounce])} phx-change="sort">
          <div class="flex flex-wrap items-center justify-between gap-4 px-4 py-3 empty:hidden">
            <div class="flex items-center gap-3 flex-grow">
              <div
                :if={
                  Enum.any?(@fields, fn
                    {_, %{searchable: true}} -> true
                    _ -> false
                  end) && @table_options.search.enabled
                }
                class="relative flex max-w-md"
              >
                <label class="sr-only">Search</label>
                <input
                  type="text"
                  name="search"
                  autocomplete="off"
                  id="table-with-pagination-search"
                  class="block w-full px-3 py-2 text-sm border border-gray-300 rounded-lg shadow-sm ps-9 focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none dark:bg-neutral-800 dark:border-neutral-700 dark:text-neutral-200 dark:placeholder-neutral-400 dark:focus:ring-neutral-600 dark:focus:border-neutral-600"
                  placeholder={@table_options[:search][:placeholder]}
                  value={@options["filters"]["search"]}
                />

                <div class="absolute inset-y-0 flex items-center pointer-events-none start-0 ps-3">
                  <svg
                    class="text-gray-400 size-4 dark:text-neutral-500"
                    xmlns="http://www.w3.org/2000/svg"
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <circle cx="11" cy="11" r="8"></circle>
                    <path d="m21 21-4.3-4.3"></path>
                  </svg>
                </div>
              </div>

              <select
                :if={@options["pagination"]["paginate?"]}
                name="per_page"
                value={@options["pagination"]["per_page"]}
                class="block px-3 py-2 text-sm border border-gray-300 rounded-lg pe-9 focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none dark:bg-neutral-800 dark:border-neutral-700 dark:text-neutral-200 dark:placeholder-neutral-400 dark:focus:ring-neutral-600"
              >
                {Phoenix.HTML.Form.options_for_select(
                  get_in(@table_options, [:pagination, :sizes]),
                  @options["pagination"]["per_page"]
                )}
              </select>
            </div>

            <button
              :if={length(@filters) > 3}
              type="button"
              phx-click="toggle_filters"
              class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-neutral-800 dark:border-neutral-700 dark:text-neutral-200 dark:hover:bg-neutral-700"
            >
              <svg
                class="w-4 h-4"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
                />
              </svg>
              <span phx-update="ignore" id="filter-toggle-text">Show Filters</span>
            </button>

            <div class="flex items-center gap-2 md:ml-auto">
              <.exports
                :if={get_in(@table_options, [:exports, :enabled])}
                formats={get_in(@table_options, [:exports, :formats])}
              />
            </div>
          </div>

          <div
            id="filters-container"
            class={["w-full", length(@filters) > 3 && "hidden"]}
            phx-hook="FilterToggle"
          >
            <.filters filters={@filters} applied_filters={@options["filters"]} />
          </div>
        </.form>
        """
      end

      defp render_content(%{table_options: %{custom_content: {module, function}}} = assigns) do
        # Call custom content component
        apply(module, function, [assigns])
      end

      defp render_content(var!(assigns)) do
        ~H"""
        <.content_section {assigns} />
        """
      end

      defp content_section(%{table_options: %{mode: :table}} = var!(assigns)) do
        ~H"""
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-300 dark:divide-neutral-700">
            <thead class="bg-gray-50 dark:bg-neutral-700">
              <tr>
                <th
                  :for={{key, field} <- @fields}
                  scope="col"
                  class="px-6 py-3 text-xs font-medium text-gray-500 uppercase text-start dark:text-neutral-500"
                >
                  <.sort_link
                    key={key}
                    label={field.label}
                    sort_params={@options["sort"]["sort_params"]}
                    sortable={field.sortable}
                  />
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-300 dark:divide-neutral-700">
              <tr class="only:block hidden">
                <td colspan={length(@fields)} class="px-4 py-8 text-center sm:px-6">
                  <div class="flex flex-col items-center justify-center space-y-2">
                    <svg
                      class="w-12 h-12 text-gray-400 dark:text-neutral-500"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M12 13h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    <p class="text-gray-500 text-base dark:text-neutral-400">No records found</p>
                    <p class="text-gray-400 text-sm dark:text-neutral-500">
                      Try adjusting your search or filters
                    </p>
                  </div>
                </td>
              </tr>
              <.render_row streams={@streams} fields={@fields} table_options={@table_options} />
            </tbody>
          </table>
        </div>
        """
      end

      defp content_section(%{table_options: %{mode: :card, use_streams: false}} = var!(assigns)) do
        ~H"""
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
          <div :for={record <- @streams}>
            {@table_options.card_component.(%{record: record})}
          </div>
        </div>
        """
      end

      defp content_section(%{table_options: %{mode: :card, use_streams: true}} = var!(assigns)) do
        ~H"""
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
          <div :for={{id, record} <- @streams.resources} id={id}>
            {@table_options.card_component.(%{record: record})}
          </div>
        </div>
        """
      end

      defp render_row(%{table_options: %{use_streams: false}} = var!(assigns)) do
        ~H"""
        <tr :for={resource <- @streams}>
          <td
            :for={{key, field} <- @fields}
            class="px-6 py-4 text-sm text-gray-800 whitespace-nowrap dark:text-neutral-200"
          >
            {render_cell(Map.get(resource, key), field, resource)}
          </td>
        </tr>
        """
      end

      defp render_row(%{table_options: %{use_streams: true}} = var!(assigns)) do
        ~H"""
        <tr :for={{id, resource} <- @streams.resources} id={id}>
          <td
            :for={{key, field} <- @fields}
            class="px-6 py-4 text-sm text-gray-800 whitespace-nowrap dark:text-neutral-200"
          >
            {render_cell(Map.get(resource, key), field, resource)}
          </td>
        </tr>
        """
      end

      defp render_row(_),
        do:
          raise(ArgumentError,
            message: "Requires `use_streams` to be set to a boolean in table_options"
          )

      defp footer_section(var!(assigns)) do
        ~H"""
        <.paginate
          :if={@options["pagination"]["paginate?"]}
          current_page={@options["pagination"]["page"]}
          has_next_page={@options["pagination"][:has_next_page]}
        />
        """
      end

      defp render_footer(%{table_options: %{custom_footer: {module, function}}} = assigns) do
        # Call custom content component
        apply(module, function, [assigns])
      end

      defp render_footer(var!(assigns)) do
        ~H"""
        <.footer_section options={@options} />
        """
      end

      def filters(var!(assigns)) do
        ~H"""
        <div class="w-full bg-gray-50 p-4 rounded-lg dark:bg-neutral-800 border border-gray-300 dark:border-neutral-700">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for {key, filter} <- @filters do %>
              <div class="flex-shrink-0">
                {filter.__struct__.render(%{
                  key: key,
                  filter: filter,
                  applied_filters: @applied_filters
                })}
              </div>
            <% end %>
          </div>
          <div class="flex justify-end mt-4 border-t border-gray-300 pt-3 dark:border-neutral-700">
            <.link
              :if={@applied_filters != %{"search" => ""}}
              phx-click="sort"
              phx-value-clear_filters="true"
              class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-neutral-700 dark:border-neutral-600 dark:text-neutral-200 dark:hover:bg-neutral-600"
            >
              <svg
                class="w-4 h-4"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
              Clear Filters
            </.link>
          </div>
        </div>
        """
      end

      def paginate(var!(assigns)) do
        ~H"""
        <div class="px-4 py-2">
          <nav class="flex items-center gap-2" aria-label="Pagination">
            <.link
              phx-click="sort"
              phx-value-page={String.to_integer(@current_page) - 1}
              class={[
                "px-3 py-1.5 text-sm border rounded-md transition flex items-center gap-1",
                if String.to_integer(@current_page) == 1 do
                  "text-gray-400 border-gray-300 pointer-events-none dark:text-neutral-500 dark:border-neutral-700"
                else
                  "text-gray-600 border-gray-300 hover:bg-gray-50 dark:text-neutral-300 dark:border-neutral-700 dark:hover:bg-neutral-800"
                end
              ]}
              aria-disabled={String.to_integer(@current_page) == 1}
              aria-label="Previous page"
            >
              <span class="sr-only">Previous</span>
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </.link>

            <span class="text-sm text-gray-600 dark:text-neutral-300">
              Page {@current_page}
            </span>

            <.link
              phx-click="sort"
              phx-value-page={String.to_integer(@current_page) + 1}
              class={[
                "px-3 py-1.5 text-sm border rounded-md transition flex items-center gap-1",
                if !@has_next_page do
                  "text-gray-400 border-gray-300 pointer-events-none dark:text-neutral-500 dark:border-neutral-700"
                else
                  "text-gray-600 border-gray-300 hover:bg-gray-50 dark:text-neutral-300 dark:border-neutral-700 dark:hover:bg-neutral-800"
                end
              ]}
              aria-label="Next page"
            >
              <span class="sr-only">Next</span>
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </.link>
          </nav>
        </div>
        """
      end

      def exports(var!(assigns)) do
        ~H"""
        <div class="flex gap-2">
          <.export_file :for={format <- @formats} type={format} />
        </div>
        """
      end

      def export_file(%{type: :csv} = var!(assigns)) do
        ~H"""
        <button
          type="button"
          phx-disable-with="Exporting CSV..."
          phx-click="export-csv"
          class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-neutral-800 dark:border-neutral-700 dark:text-neutral-200 dark:hover:bg-neutral-700"
        >
          <svg
            class="w-4 h-4"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
          Export CSV
        </button>
        """
      end

      def export_file(%{type: :pdf} = var!(assigns)) do
        ~H"""
        <button
          type="button"
          phx-disable-with="Exporting PDF..."
          phx-click="export-pdf"
          class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-neutral-800 dark:border-neutral-700 dark:text-neutral-200 dark:hover:bg-neutral-700"
        >
          <svg
            class="w-4 h-4"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
          Export PDF
        </button>
        """
      end

      defp render_cell(value, %{renderer: renderer}, record) when is_function(renderer, 2) do
        renderer.(value, record)
      end

      defp render_cell(value, %{renderer: renderer}, _record) when is_function(renderer, 1) do
        renderer.(value)
      end

      defp render_cell(value, _field, _record), do: value
    end
  end
end
