# Exports
## Export Support

LiveTable supports both CSV and PDF exports with background processing:

- CSV exports are handled by LiveTable.CsvGenerator
- PDF exports use Typst for formatting and generation. Handled by LiveTable.PdfGenerator
- Automatic file cleanup

## Customization

### Custom Components

You can provide your own components module:

```elixir
config :live_table,
  components: MyApp.CustomComponents
```

### Custom Styling

The library uses Tailwind CSS by default, but you can customize the appearance by:

1. Overriding the default classes in the configuration
2. Providing custom templates for components

## Background Processing

LiveTable uses Oban for handling resource-intensive export operations asynchronously, preventing LiveView timeouts and ensuring a smooth user experience.

### How it Works

1. **Job Queuing**
   When a user requests an export, LiveTable:
   - Generates a unique export topic
   - Subscribes the LiveView process to this topic
   - Queues an Oban job with the export parameters

```elixir
def handle_event("export-csv", _params, socket) do
  {export_topic, updated_socket} = maybe_subscribe(socket)

  {:ok, _job} =
    %{
      query: query_string,
      header_data: header_data,
      topic: export_topic
    }
    |> LiveTable.Workers.CsvExportWorker.new()
    |> Oban.insert()

  {:noreply, updated_socket}
end
```

2. **Background Processing**
   The Oban worker processes the export in the background:
   - Streams data in chunks to manage memory usage
   - Monitors progress
   - Generates the export file

```elixir
# In CsvExportWorker
def perform(%Oban.Job{args: %{"header_data" => header_data, "query" => query, "topic" => topic}}) do
  case LiveTable.CsvGenerator.generate_csv(query, header_data) do
    {:ok, file_path} ->
      Phoenix.PubSub.broadcast(
        Application.fetch_env!(:live_table, :pubsub),
        topic,
        {:file_ready, file_path}
      )
      :ok
  end
end
```

4. **File Delivery**
   Once the export is complete:
   - The worker broadcasts a `:file_ready` message
   - The LiveView triggers the file download
   - The temporary file is automatically cleaned up

```elixir
# In your LiveView
def handle_info({:file_ready, file_path}, socket) do
  socket =
    socket
    |> push_event("download", %{path: "/exports/#{filename}"})
    |> put_flash(:info, "File downloaded successfully.")

  Process.send_after(self(), {:cleanup_file, dest_path}, :timer.seconds(20))
  {:noreply, socket}
end
```

### Configuration

Configure the export queue in your Oban config:

```elixir
config :your_app, Oban,
  queues: [exports: 10]  # Adjust concurrency as needed
```

### Supported Export Formats

- **CSV Export**: Efficient streaming of large datasets
- **PDF Export**: Uses Typst for professional-looking documents

Both export types support:
- Custom headers and formatting
- Progress tracking
- Automatic file cleanup
- Error handling and retry logic
