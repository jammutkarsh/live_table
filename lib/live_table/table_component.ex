defmodule LiveTable.TableComponent do
  @moduledoc false
  use Phoenix.Component
  import LiveTable.SortHelpers
  # Renders the main table component with search, pagination, filters and export options
  def live_table(assigns) do
    ~H"""
    <div class="flex flex-col" id=" live-table" phx-hook="Download">
      <div class="-m-1.5 overflow-x-auto">
        <div class="p-1.5 min-w-full inline-block align-middle">
          <div class="border divide-y divide-gray-200 rounded-lg ark:border-neutral-700 ark:divide-neutral-700">
            <.form for={%{}} phx-debounce="300" phx-change="sort">
              <div class="flex px-4 py-3">
                <div
                  :if={
                    Enum.any?(@fields, fn
                      {_, %{searchable: true}} -> true
                      _ -> false
                    end)
                  }
                  class="relative flex max-w-md"
                >
                  <label class="sr-only">Search</label>
                  <input
                    type="text"
                    name="search"
                    autocomplete="off"
                    id="table-with-pagination-search"
                    class="block w-full px-3 py-2 text-sm border-gray-200 rounded-lg shadow-sm ps-9 focus:z-10 focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none ark:bg-neutral-900 ark:border-neutral-700 ark:text-neutral-400 ark:placeholder-neutral-500 ark:focus:ring-neutral-600"
                    placeholder="Search for items"
                    value={@options["filters"]["search"]}
                  />

                  <div class="absolute inset-y-0 flex items-center pointer-events-none start-0 ps-3">
                    <svg
                      class="text-gray-400 size-4 ark:text-neutral-500"
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
                  name="per_page"
                  value={@options["pagination"]["per_page"]}
                  class="block px-3 py-2 text-sm border-gray-200 rounded-lg pe-9 focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none ark:bg-neutral-900 ark:border-neutral-700 ark:text-neutral-400 ark:placeholder-neutral-500 ark:focus:ring-neutral-600"
                >
                  {Phoenix.HTML.Form.options_for_select(
                    ["10", "25", "50"],
                    @options["pagination"]["per_page"]
                  )}
                </select>

                <.filters filters={@filters} applied_filters={@options["filters"]} />
                <.exports />
              </div>
            </.form>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200 ark:divide-neutral-700">
                <thead class="bg-gray-50 ark:bg-neutral-700">
                  <tr>
                    <th
                      :for={{key, field} <- @fields}
                      scope="col"
                      class="px-6 py-3 text-xs font-medium text-gray-500 uppercase text-start ark:text-neutral-500"
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
                <tbody class="divide-y divide-gray-200 ark:divide-neutral-700">
                  <tr class="only:block hidden">
                    <td colspan={length(@fields)} class="px-4 py-8 text-center sm:px-6">
                      <div class="flex flex-col items-center justify-center space-y-2">
                        <svg
                          class="w-12 h-12 text-gray-400"
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
                        <p class="text-gray-500 text-base">No records found</p>
                        <p class="text-gray-400 text-sm">Try adjusting your search or filters</p>
                      </div>
                    </td>
                  </tr>
                  <tr :for={{id, resource} <- @streams.resources} id={id}>
                    <td
                      :for={{key, _field} <- @fields}
                      class="px-6 py-4 text-sm text-gray-800 whitespace-nowrap ark:text-neutral-200"
                    >
                      {Map.get(resource, key)}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <.paginate
              :if={@options["pagination"]["paginate?"]}
              current_page={@options["pagination"]["page"]}
              has_next_page={@options["pagination"][:has_next_page]}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Renders filter options based on provided filters configuration
  def filters(assigns) do
    ~H"""
    <div class="flex justify-between">
      <%= for {key, filter} <- @filters do %>
        {filter.__struct__.render(%{
          key: key,
          filter: filter,
          applied_filters: @applied_filters
        })}
      <% end %>
      <.link
        :if={@applied_filters != %{"search" => ""}}
        phx-click="sort"
        phx-value-clear_filters="true"
        class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-200 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 ark:bg-neutral-900 ark:border-neutral-700 ark:text-white ark:hover:bg-neutral-800"
      >
        Clear Filters
      </.link>
    </div>
    """
  end

  # Renders pagination controls with previous/next buttons and current page display
  def paginate(assigns) do
    ~H"""
    <div class="px-4 py-2">
      <nav class="flex items-center gap-2" aria-label="Pagination">
        <.link
          phx-click="sort"
          phx-value-page={String.to_integer(@current_page) - 1}
          class={[
            "px-3 py-1.5 text-sm border rounded-md transition flex items-center gap-1",
            if String.to_integer(@current_page) == 1 do
              "text-gray-400 border-gray-200 pointer-events-none"
            else
              "text-gray-600 border-gray-300 hover:bg-gray-50"
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

        <span class="text-sm text-gray-600">
          Page {@current_page}
        </span>

        <.link
          phx-click="sort"
          phx-value-page={String.to_integer(@current_page) + 1}
          class={[
            "px-3 py-1.5 text-sm border rounded-md transition flex items-center gap-1",
            if !@has_next_page do
              "text-gray-400 border-gray-200 pointer-events-none"
            else
              "text-gray-600 border-gray-300 hover:bg-gray-50"
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

  # Renders CSV and PDF export buttons with loading states
  def exports(assigns) do
    ~H"""
    <div class="flex gap-2">
      <button
        type="button"
        phx-disable-with="Exporting CSV..."
        phx-click="export-csv"
        class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-200 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 ark:bg-neutral-900 ark:border-neutral-700 ark:text-white ark:hover:bg-neutral-800"
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

      <button
        type="button"
        phx-disable-with="Exporting PDF..."
        phx-click="export-pdf"
        class="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-gray-800 bg-white border border-gray-200 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 ark:bg-neutral-900 ark:border-neutral-700 ark:text-white ark:hover:bg-neutral-800"
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
    </div>
    """
  end
end
