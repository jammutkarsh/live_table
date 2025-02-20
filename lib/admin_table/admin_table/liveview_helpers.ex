defmodule AdminTable.LiveViewHelpers do
  defmacro __using__(opts) do
    quote do
      @resource_name unquote(opts[:resource])

      @impl true
      def handle_params(params, _url, socket) do
        sort_params =
          Map.get(params, "sort_params", %{"id" => "asc"})
          |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_atom(v)} end)

        filters =
          Map.get(params, "filters", %{})
          |> Map.put("search", params["search"] || "")
          |> Enum.reduce(%{}, fn
            {"search", search_term}, acc ->
              Map.put(acc, "search", search_term)

            {key, %{"min" => min, "max" => max}}, acc ->
              filter = get_filter(key)
              {min_val, max_val} = parse_range_values(filter.options.type, min, max)
              filter = %{filter | options: %{filter.options | min: min_val, max: max_val}}
              key = key |> String.to_atom()
              Map.put(acc, key, filter)

            {key, %{"id" => id}}, acc ->
              filter = %AdminTable.Select{} = get_filter(key)
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
            "sortable?" => true,
            "sort_params" => sort_params
          },
          "pagination" => %{
            "paginate?" => true,
            "page" => params["page"] || "1",
            "per_page" => params["per_page"] || "10"
          },
          "filters" => filters
        }

        socket =
          socket
          |> stream(:resources, stream_resources(fields(), options), reset: true)
          |> assign(:options, options)

        {:noreply, socket}
      end

      @impl true
      def handle_event("sort", params, socket) do
        shift_key = Map.get(params, "shift_key", false)
        sort_params = Map.get(params, "sort", nil)
        filter_params = Map.get(params, "filters", nil)

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
          |> push_patch(to: ~p"/#{@resource_name}?#{options}")

        {:noreply, socket}
      end

      def handle_event("live_select_change", %{"text" => text, "id" => id}, socket) do
        options =
          case get_filter(id) do
            %AdminTable.Select{
              options: %{options: _options, options_source: {module, function, args}}
            } ->
              apply(module, function, [text | args])

            %AdminTable.Select{options: %{options: options, options_source: nil}} ->
              options
          end

        send_update(LiveSelect.Component, id: id, options: options)

        {:noreply, socket}
      end

      def handle_event("export-csv", _params, socket) do
        header_data =
          fields()
          |> Enum.reduce([[], []], fn {k, %{label: label}}, [key_names, headers] ->
            [[k | key_names], [label | headers]]
          end)
          |> Enum.map(&Enum.reverse/1)

        options = socket.assigns.options |> put_in(["pagination", "paginate?"], false)

        query_string = list_resources(fields(), options) |> inspect()

        {:ok, _job} =
          %{
            query: query_string,
            header_data: header_data
          }
          |> AdminTable.Workers.CsvExportWorker.new()
          |> Oban.insert()

        {:noreply, socket}
      end

      def handle_event("export-pdf", _params, socket) do
        options = socket.assigns.options

        header_data =
          fields()
          |> Enum.reduce([[], []], fn {k, %{label: label}}, [key_names, headers] ->
            [[k | key_names], [label | headers]]
          end)
          |> Enum.map(&Enum.reverse/1)

        query_string = list_resources(fields(), options) |> inspect()

        {:ok, _job} =
          %{
            query: query_string,
            header_data: header_data
          }
          |> AdminTable.Workers.PdfExportWorker.new()
          |> Oban.insert()

        {:noreply, socket}
      end

      @impl true
      def handle_info({:file_ready, file_path}, socket) do
        static_path = Path.join([:code.priv_dir(:admin_table), "static", "exports"])
        File.mkdir_p!(static_path)

        filename = Path.basename(file_path)
        dest_path = Path.join(static_path, filename)
        File.cp!(file_path, dest_path)

        socket =
          socket
          |> push_event("download", %{path: "/exports/#{filename}"})
          |> put_flash(:info, "File downloaded successfully.")

        Process.send_after(self(), {:cleanup_file, dest_path}, :timer.seconds(20))
        File.rm(file_path)
        {:noreply, socket}
      end

      def handle_info({:cleanup_file, file_path}, socket) do
        File.rm(file_path)
        {:noreply, socket}
      end
    end
  end
end
