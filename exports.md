# Exports
## Export Support

LiveTable supports both CSV and PDF exports with background processing. 
It uses Oban to handle bakground jobs, so that export file can be prepared without hanging the LiveView.

- CSV exports are handled by [`LiveTable.CsvGenerator`](https://github.com/gurujada/live_table/blob/master/lib/live_table/csv_generator.ex).
  Makes use of [`NimbleCSV`](https://hex.pm/packages/nimble_csv) under the hood.
- PDF exports use [`Typst`](https://typst.app/universe) for formatting and generation. Handled by [`LiveTable.PdfGenerator`](https://github.com/gurujada/live_table/blob/master/lib/live_table/pdf_generator.ex)

The headers are the same as that rendered by the table. By default, all records are exported without pagination. 


## Configuration
### Oban
Configure your Oban instance and queues in your `config.exs`:

```elixir
# config/config.exs
config :live_table, Oban,
  repo: YourApp.Repo,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  plugins: [Oban.Plugins.Pruner],
  queues: [exports: 10]
  # the queue named `exports` will be used for export jobs
```

#### Oban Web: Optional
You can configure oban web in your router to monitor the background jobs.
  
  ```elixir
  # lib/your_app_web/router.ex
  import Oban.Web.Router
 
  scope "/", YouAppWeb do
    # your other routes
    oban_dashboard("/oban")
  end
  ```

> **Note**: Remember to add exports to your list of allowed static paths in `lib/app_web.ex`

```elixir
def static_paths, do: ~w(assets fonts images favicon.ico exports robots.txt)
```


## CSV Exports
LiveTable uses [`NimbleCSV`](https://hex.pm/packages/nimble_csv) in conjunction with Oban for handling CSV exports.
Records are streamed inside of a [`Repo.transaction/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:transaction/2) function using [`Repo.stream/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:stream/2),
so that no more than a 1000 records are loaded into memory at a time.
This makes it extremely efficient and blazing fast for exporting large datasets, all the while remaining scalable.

## PDF Exports
LiveTable uses [`Typst`](https://typst.app/universe) in conjunction with Oban for handling PDF exports.
Typst is a Rust based typesetting engine that generates PDFs from .tp files
This makes it extremely fast and well suited to handle large datasets.

Records are streamed inside of a [`Repo.transaction/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:transaction/2) function using [`Repo.stream/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:stream/2),
so that no more than a 500 records are loaded into memory at a time.

> **Note**: LiveTable uses `System.cmd/2` to compile the .tp file into a PDF. Ensure that you have `typst` installed on your system.
