defmodule LiveTable.LiveViewHelpers do
  @moduledoc false
  defmacro __using__(opts) do
    quote do
      use LiveTable.ExportHelpers
      use LiveTable.FilterToggleHelpers

      @impl true
      # Fetches records based on URL params
      def handle_params(params, url, socket) do
        default_sort = get_in(unquote(opts[:table_options]), [:sorting, :default_sort])
        current_path = URI.parse(url).path |> String.trim_leading("/")

        sort_params =
          Map.get(params, "sort_params", default_sort)
          |> Enum.map(fn
            # for default case
            {k, v} when is_atom(k) and is_atom(v) -> {k, v}
            # for incoming params from url
            {k, v} -> {String.to_existing_atom(k), String.to_existing_atom(v)}
          end)

        filters =
          Map.get(params, "filters", %{})
          |> Map.put("search", params["search"] || "")
          |> Enum.reduce(%{}, fn
            {"search", search_term}, acc ->
              Map.put(acc, "search", search_term)

            {key, %{"min" => min, "max" => max}}, acc ->
              filter = get_filter(key)
              {min_val, max_val} = parse_range_values(filter.options.type, min, max)

              updated_filter =
                filter
                |> Map.update!(:options, fn options ->
                  options
                  |> Map.put(:current_min, min_val)
                  |> Map.put(:current_max, max_val)
                end)

              key = String.to_atom(key)
              Map.put(acc, key, updated_filter)

            {key, %{"id" => id}}, acc ->
              filter = %LiveTable.Select{} = get_filter(key)
              id = id |> Enum.map(&String.to_integer/1)
              filter = %{filter | options: Map.update!(filter.options, :selected, &(&1 ++ id))}
              key = key |> String.to_existing_atom()
              Map.put(acc, key, filter)

            {k, _}, acc ->
              key = k |> String.to_existing_atom()
              Map.put(acc, key, get_filter(k))
          end)

        options = %{
          "sort" => %{
            "sortable?" => get_in(unquote(opts[:table_options]), [:sorting, :enabled]),
            "sort_params" => sort_params
          },
          "pagination" => %{
            "paginate?" => get_in(unquote(opts[:table_options]), [:pagination, :enabled]),
            "page" => params["page"] |> validate_page_num(),
            "per_page" => params["per_page"] |> validate_per_page()
          },
          "filters" => filters
        }

        {resources, updated_options} =
          case stream_resources(fields(), options) do
            {resources, overflow} ->
              has_next_page = length(overflow) > 0
              options = put_in(options["pagination"][:has_next_page], has_next_page)
              {resources, options}

            resources when is_list(resources) ->
              {resources, options}
          end

        schema = unquote(opts[:schema])
        table_name = schema.__schema__(:source)

        # Update LiveSelect components with selected values from URL params
        socket =
          socket
          |> stream(:resources, resources,
            dom_id: fn resource ->
              "#{table_name}-#{Ecto.UUID.generate()}"
            end,
            reset: true
          )
          |> assign(:options, updated_options)
          |> assign(:current_path, current_path)

        # Update LiveSelect components with selected values from URL params
        for {key, filter} <- filters do
          case filter do
            %LiveTable.Select{options: %{selected: selected}} when selected != [] ->
              # Get the options for this filter
              options =
                case filter.options do
                  %{options: options} when is_list(options) and options != [] ->
                    options

                  %{options_source: {module, function, args}} ->
                    apply(module, function, ["" | args])

                  _ ->
                    []
                end

              # Find the selected options based on the selected IDs
              selected_options =
                Enum.map(selected, fn id ->
                  Enum.find(options, fn
                    %{value: [option_id, _]} -> option_id == id
                    _ -> false
                  end)
                end)
                |> Enum.reject(&is_nil/1)

              # Update the LiveSelect component with the selected options
              if selected_options != [] do
                send_update(LiveSelect.Component, id: filter.key, value: selected_options)
              end

            _ ->
              :ok
          end
        end

        {:noreply, socket}
      end

      defp validate_page_num(nil), do: "1"

      defp validate_page_num(n) when is_binary(n) do
        try do
          num = String.to_integer(n)

          cond do
            num > 0 -> n
            true -> "1"
          end
        rescue
          ArgumentError -> "1"
        end
      end

      defp validate_per_page(nil), do: "10"

      defp validate_per_page(n) when is_binary(n) do
        try do
          num = String.to_integer(n)

          cond do
            num > 0 and num <= 50 -> n
            true -> "50"
          end
        rescue
          ArgumentError -> "10"
        end
      end

      @impl true
      # Handles all LiveTable related events like sort, paginate and filter

      def handle_event("sort", %{"clear_filters" => "true"}, socket) do
        current_path = socket.assigns.current_path

        options =
          socket.assigns.options
          |> Enum.reduce(%{}, fn
            {"filters", _v}, acc ->
              Map.put(acc, "filters", %{})

            {_, v}, acc when is_map(v) ->
              Map.merge(acc, v)
          end)
          |> Map.take(~w(page per_page sort_params))
          |> Map.reject(fn {_, v} -> v == "" || is_nil(v) end)

        socket =
          socket
          |> push_patch(to: "/#{current_path}?#{Plug.Conn.Query.encode(options)}")

        {:noreply, socket}
      end

      def handle_event("sort", params, socket) do
        shift_key = Map.get(params, "shift_key", false)
        sort_params = Map.get(params, "sort", nil)
        filter_params = Map.get(params, "filters", nil)
        current_path = socket.assigns.current_path

        options =
          socket.assigns.options
          |> Enum.reduce(%{}, fn
            {"filters", %{"search" => search_term} = v}, acc ->
              filters = encode_filters(v)
              Map.put(acc, "filters", filters) |> Map.put("search", search_term)

            {_, v}, acc when is_map(v) ->
              Map.merge(acc, v)
          end)
          |> Map.merge(params, fn
            "filters", v1, v2 when is_map(v1) and is_map(v2) -> v1
            _, _, v -> v
          end)
          |> update_sort_params(sort_params, shift_key)
          |> update_filter_params(filter_params)
          |> Map.take(~w(page per_page search sort_params filters))
          |> Map.reject(fn {_, v} -> v == "" || is_nil(v) end)

        socket =
          socket
          |> push_patch(to: "/#{current_path}?#{Plug.Conn.Query.encode(options)}")

        {:noreply, socket}
      end

      # Handles live select filter changes by:
      # - Fetching new options based on text input
      # - Updating the LiveSelect component
      # TODO: Filter state should update based on URL params
      # TODO: Add multi-tag support
      # TODO: Move away from live_select

      def handle_event("live_select_change", %{"text" => text, "id" => id}, socket) do
        options =
          case get_filter(id) do
            %LiveTable.Select{
              options: %{options: _options, options_source: {module, function, args}}
            } ->
              apply(module, function, [text | args])

            %LiveTable.Select{options: %{options: options, options_source: nil}} ->
              options
          end

        send_update(LiveSelect.Component, id: id, options: options)

        {:noreply, socket}
      end
    end
  end
end
