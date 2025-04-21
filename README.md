# Live Table

  LiveTable is a powerful Phoenix LiveView component library that provides dynamic, interactive tables with built-in support for sorting, filtering, pagination, and data export capabilities.
  Makes use of [`Oban`](https://hex.pm/packages/oban), [`NimbleCSV`](https://hex.pm/packages/nimble_csv) and [`Typst`](https://typst.app/universe) to handle exports.

  **You can find a table with 1 Million rows [here](https://live-table.fly.dev)**

![Demo](https://github.com/gurujada/live_table/blob/master/demo.png?raw=true)

## Features

  - **Advanced Filtering System**
    - Text search across multiple fields
    - Range filters for numbers, dates, and datetimes
    - Boolean filters with custom conditions
    - Select filters with static and dynamic options
    - Multi-column filtering support

  - **Smart Sorting**
    - Multi-column sorting
    - Sortable associated fields
    - Customizable sort directions
    - Shift-click support for multi-column sorting

  - **Flexible Pagination**
    - Configurable page sizes
    - Dynamic page navigation
    - Efficient database querying

  - **Export Capabilities**
    - CSV export with background processing
    - PDF export using Typst
    - Custom file naming and formatting
    - Progress tracking for large exports

  - **Real-time Updates**
    - LiveView integration
    - Instant filter feedback
    - Background job status updates

## Installation

  Add `live_table` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:live_table, "~> 0.3.0"}
    ]
  ```

## Configuration

  Configure LiveTable in your `config/config.exs`:

  ```elixir
  config :live_table,
    repo: YourApp.Repo,
    pubsub: YourApp.PubSub,
    components: YourApp.Components  # Optional, defaults to LiveTable.Components
  ```

### JavaScript Setup

  Add the following to `assets/js/app.js`:

  ```js
  import { TableHooks } from "../../deps/live_table/priv/static/live-table.js"
  let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: TableHooks
  })
  ```

### CSS Setup

Add the following to `assets/tailwind.config.js`:

```javascript
content: [
  // Other paths
  "../deps/live_table/priv/static/*.js",
  "../deps/live_table/**/*.*ex"
]
```
And add the following to `assets/css/app.css`:
```css
@import "../../deps/live_table/priv/static/live-table.css";
```

## Basic Usage

  LiveTable's functionality can be imported with the `use` command.
  LiveTable needs a schema, which will be called the base-schema. Query is built with the base-schema as the foundation. Base-schema will be used to search for all associated fields.

  Define your fields and filters as required.
  ```elixir
  # In liveview
  defmodule MyAppWeb.UserLive.Index do
    use MyAppWeb, :live_view
    use LiveTable.LiveResource, resource: "users", schema: User # Add this line

    # Define fields
    def fields do
      [
        id: %{label: "ID", sortable: true},
        name: %{label: "Name", sortable: true, searchable: true},
        email: %{label: "Email", sortable: true, searchable: true},
      ]
    end

    # Define filters
    def filters do
      [
        active: Boolean.new(:active, "active", %{
          label: "Active Users",
          condition: dynamic([q], q.active == true)
        })
      ]
    end
  ```

  ```elixir
    # in corresponding view:
    <.live_table
      fields={fields()}
      filters={filters()}
      options={@options}
      streams={@streams}
    />
  ```

## Defining fields and filters
### Fields
Fields are to be defined under the `fields()` function in the same liveview where LiveResource is called.

It should return a keyword list where each key represents a field and maps to configuration options for that field.

**A detailed guide on defining all types of fields is available [here](fields.html)**

### Filters
  Similar to fields, filters should be defined under the `filters()` function in the same liveview.

  It should return a keyword list where each key is used to reference the filter, and points to a corresponding struct.

  **A detailed guide on defining all types of fields is available [here](filters.html)**
