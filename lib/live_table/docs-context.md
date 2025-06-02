# Livetable Elixir Library Documentation Planning

## User

go around the app and understand it fully. this is livetable - an library for elixir that helps to build realtime reusable datatables for phoenix liveview. 
I want you to have a clear understanding of it. 

As you can see, the docs are out of date. several new features have been brought in. even the existing docs aren't that great.
I want you to rewrite the entire documentation for this library. keep it concise, informative, crisp. the end users are developers. it should be developer friendly and easy to understand. 

make a detailed plan on how to write docs.it will be used as context for you later. first make a plan, if we both agree on it, then you can proceed. youre not a code writer. dont agree blindly with me. either question or suggest enhancements.

## Agent

I'll help you understand the LiveTable library and create a comprehensive documentation plan. Let me start by exploring the codebase to understand its structure, features, and current state.

**Use Tool: list_directory (toolu_vrtx_01NNaBpoQUBFYoZqQ2zHVvJa)**
```json
{
  "path": "live_table"
}
```

**Tool Results: toolu_vrtx_01NNaBpoQUBFYoZqQ2zHVvJa**

live_table/.elixir_ls
live_table/.formatter.exs
live_table/.gitignore
live_table/LICENSE
live_table/README.md
live_table/_build
live_table/assets
live_table/config
live_table/context.md
live_table/demo.png
live_table/deps
live_table/doc
live_table/docs-context.md
live_table/exports.md
live_table/fields.md
live_table/filters.md
live_table/lib
live_table/mix.exs
live_table/mix.lock
live_table/priv
live_table/table_config.md
live_table/test

## Agent

**Use Tool: read_file (toolu_vrtx_01RGKv26yTUDLnPHjB9fRiFv)**
```json
{
  "path": "live_table/README.md"
}
```

**Tool Results: toolu_vrtx_01RGKv26yTUDLnPHjB9fRiFv**

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

LiveTable uses DaisyUI components for styling. First, install DaisyUI in your project:

```bash
npm install daisyui@latest
```

Add DaisyUI to your `assets/tailwind.config.js`:

```javascript
module.exports = {
  content: [
    // Other paths
    "../deps/live_table/priv/static/*.js",
    "../deps/live_table/**/*.*ex"
  ],
  plugins: [
    require("daisyui")
  ],
  daisyui: {
    themes: ["light", "dark"], // or specify your preferred themes
  }
}
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

## Agent

**Use Tool: read_file (toolu_vrtx_01FmLKMx8tqUtbV4EKRYWBMS)**
```json
{
  "path": "live_table/mix.exs"
}
```

**Tool Results: toolu_vrtx_01FmLKMx8tqUtbV4EKRYWBMS**

defmodule LiveTable.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/gurujada/live_table"

  def project do
    [
      app: :live_table,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description:
        "A powerful LiveView component for creating dynamic, interactive tables with features like sorting, filtering, pagination, and export capabilities.",
      docs: docs()
    ]
  end

  def application do
    [
      mod: {LiveTable.TestApplication, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_html, "~> 4.1"},
      {:ecto, "~> 3.10"},
      {:jason, "~> 1.2"},
      {:nimble_csv, "~> 1.2"},
      {:oban, "~> 2.19"},
      {:live_select, "~> 1.5.4"},
      {:oban_web, "~> 2.11"},
      {:postgrex, ">= 0.0.0"},
      {:ex_doc, "~> 0.30", runtime: false},
      {:ecto_sql, "~> 3.10"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Chivukula Virinchi"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/live_table"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE priv/static/)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "readme",
      name: "LiveTable",
      source_url: @source_url,
      extras: ["README.md", "fields.md", "filters.md", "table_config.md", "exports.md"],
      source_ref: "v#{@version}"
    ]
  end
end

## Agent

**Use Tool: list_directory (toolu_vrtx_01UyNKZzu6FNXXecBqCRVgZR)**
```json
{
  "path": "live_table/lib"
}
```

**Tool Results: toolu_vrtx_01UyNKZzu6FNXXecBqCRVgZR**

live_table/lib/live_table
live_table/lib/live_table.ex

## Agent

**Use Tool: list_directory (toolu_vrtx_01GjXVeFkYLddeUvL23ez12B)**
```json
{
  "path": "live_table/lib/live_table"
}
```

**Tool Results: toolu_vrtx_01GjXVeFkYLddeUvL23ez12B**

live_table/lib/live_table/application.ex
live_table/lib/live_table/boolean.ex
live_table/lib/live_table/components.ex
live_table/lib/live_table/csv_generator.ex
live_table/lib/live_table/export_helpers.ex
live_table/lib/live_table/filter.ex
live_table/lib/live_table/filter_helpers.ex
live_table/lib/live_table/filter_toggle_helpers.ex
live_table/lib/live_table/helpers.ex
live_table/lib/live_table/join.ex
live_table/lib/live_table/live_resource.ex
live_table/lib/live_table/liveview_helpers.ex
live_table/lib/live_table/paginate.ex
live_table/lib/live_table/pdf_generator.ex
live_table/lib/live_table/range.ex
live_table/lib/live_table/repo.ex
live_table/lib/live_table/select.ex
live_table/lib/live_table/sort_helpers.ex
live_table/lib/live_table/sorting.ex
live_table/lib/live_table/table_component.ex
live_table/lib/live_table/table_config.ex
live_table/lib/live_table/workers

## Agent

**Use Tool: read_file (toolu_vrtx_01V87CeaD1b9B6w87iPL2C5q)**
```json
{
  "path": "live_table/lib/live_table.ex"
}
```

**Tool Results: toolu_vrtx_01V87CeaD1b9B6w87iPL2C5q**

defmodule LiveTable do
  @moduledoc """

    LiveTable is a powerful Phoenix LiveView component library that provides dynamic, interactive tables with built-in support for sorting, filtering, pagination, and data export capabilities.
    Makes use of [`Oban`](https://hex.pm/packages/oban), [`NimbleCSV`](https://hex.pm/packages/nimble_csv) and [`Typst`](https://typst.app/universe) to handle exports.

  **You can find a table with 1 Million rows [here](https://live-table.fly.dev)**
  ![Demo](demo.png)

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
        {:live_table, "~> 0.2.0"}
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

    Add the following to your `assets/js/app.js`:

    ```js
    import { TableHooks } from "../../deps/live_table/priv/static/live-table.js"
    let liveSocket = new LiveSocket("/live", Socket, {
      params: {_csrf_token: csrfToken},
      hooks: TableHooks
    })
    ```

  ### CSS Setup

  Add the following to your `assets/tailwind.config.js`:

  ```javascript
  content: [
    // Other paths
    "../deps/live_table/priv/static/*.js",
    "../deps/live_table/**/*.*ex"
  ]
  ```
  And add the following to your `assets/css/app.css`:
  ```css
  @import "../../deps/live_table/priv/static/live-table.css";
  ```

  ### Oban
  Configure your Oban instance and queues in your `config/config.exs`:

  ```elixir
  # config/config.exs
  config :your_app, Oban,
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

  > **Note**: Remember to add exports to your list of allowed `static_paths` in `lib/app_web.ex`

  ```elixir
  def static_paths, do: ~w(assets fonts images favicon.ico exports robots.txt)
  ```

  ## Basic Usage

    In your LiveView add the line `use LiveTable.LiveResource`:

    Define your fields and filters as required.
    ```elixir
    #/app_web/live/user_live/index.ex
    defmodule MyAppWeb.UserLive.Index do
      use MyAppWeb, :live_view
      use LiveTable.LiveResource, resource: "users", schema: User # Add this line

      # Define fields
      def fields do
        [
          id: %{label: "ID", sortable: true},
          name: %{label: "Name", sortable: true, searchable: true},
          email: %{label: "Email", sortable: true, searchable: true},

          # Include fields from associations
          supplier: %{
            label: "Supplier",
            sortable: true,
            searchable: true,
            assoc: {:supplier, :name}
          }
        ]
      end

      # Define filters
      def filters do
        [
          # Boolean filter
          active: Boolean.new(:active, "active", %{
            label: "Active Users",
            condition: dynamic([q], q.active == true)
          }),

          # Range filter
          age: Range.new(:age, "age", %{
            type: :number,
            label: "Age Range",
            min: 0,
            max: 100
          }),

          # Select filter with dynamic options
          supplier: Select.new({:suppliers, :name}, "supplier", %{
            label: "Supplier",
            options_source: {YourApp.Suppliers, :search_suppliers, []}
          })
        ]
      end
    ```

    ```elixir
      #/app_web/live/user_live/index.html.heex
      # in your view:
      <.live_table
        fields={fields()}
        filters={filters()}
        options={@options}
        streams={@streams}
      />
    ```
  > **Note**: Using `shift` + click on a column header will sort by multiple columns.

  ## Filter Types

  ### Boolean Filter

    ```elixir
    Boolean.new(:active, "active_filter", %{
      label: "Show Active Only",
      condition: dynamic([p], p.active == true)
    })
    ```

  ### Range Filter

    ```elixir
    Range.new(:price, "price_range", %{
      type: :number,
      label: "Price Range",
      min: 0,
      max: 1000,
      step: 10
    })
    ```

  ### Select Filter

    ```elixir
    Select.new(:category, "category_select", %{
      label: "Category",
      options: [
        %{label: "Electronics", value: [1, "Electronics"]},
        %{label: "Books", value: [2, "Books"]}
      ]
    })
    ```

  ## Defining your fields
  ### Normal Fields
    The fields you want should be defined under the fields() function. This function needs to be passed to the live_table component in the template.
    A basic guide to defining fields is as follows:

    Define them as a keyword list, with the key being the name of the field (which will appear in the url and be used to reference the field) and a map of options which will contain more data about the field.
    For eg,
    ```elixir
      def fields() do
        [
        id: %{label: "ID", sortable: true},
        name: %{label: "Name", sortable: true, searchable: true},
        email: %{label: "Email", sortable: true, searchable: true},
        ]
      end
    ```
    The map contains the label, and config for sort and search. The label will be the column header in the table and the exported CSV/PDF.


    **Only fields with `sortable: true` will have a sortable link generated as the column header**.


    **All fields with `searchable: true` will be searched from the search bar using the `ILIKE` operator**.

  ### Associated Fields
    For associated fields, you can use the `assoc` key to specify the association, with a tuple containing the table name and the field.
    For eg,
    ```elixir
      def fields() do
        [
        id: %{label: "ID", sortable: true},
        supplier: %{
          label: "Supplier",
          sortable: true,
          searchable: true,
          assoc: {:supplier, :name}
        },
        supplier_description: %{
          label: "Supplier Email",
          assoc: {:suppliers, :contact_info},
          searchable: false,
          sortable: true
        },
        category_name: %{
          label: "Category Name",
          assoc: {:category, :name},
          searchable: false,
          sortable: false
        },
        image: %{
          label: "Image",
          sortable: false,
          searchable: false,
          assoc: {:image, :url}
        },
        ]
      end
    ```
    Be it any type of association, you can join using the `assoc` key.

  ### Computed Fields
    You can also define computed fields, which are fields that are not present in the database but are computed using a function.
    This is useful in cases like calculating the total price of a product based on the quantity and price.
    Such fields require a `computed:` key, which should get a dynamic query expression.

    Since it is a dynamic query, you can use it to alias associated fields and use them inside the fragment.
    For eg,
    ```elixir
      def fields() do
        [
          amount: %{
            label: "Amount",
            sortable: true,
            searchable: false,
            computed: dynamic([resource: r, suppliers: s, categories: c], fragment("? * ?", r.price, r.stock_quantity))
          }
        ]
      end
    ```

    If the field has not already been joined by a previous field, you can join it in the computed field itself.
    For eg,
    ```elixir
      def fields() do
        [
          amount: %{
            label: "Amount",
            sortable: true,
            searchable: false,
            assoc: {:image, :url}
            computed: dynamic([resource: r, images: i], fragment("? * ?", r.price, r.stock_quantity)),
          }
        ]
      end
    ```

  ## Defining your filters
    Your filters should be defined under the filters() function. This function needs to be passed to the live_table component in the template.
    A basic guide to defining them is as follows:

    Define them as a keyword list, with the key being the name of the filter (which will appear in the url and be used to reference the filter) and a map of options which will contain more info about the filter.

    Each filter is defined by a struct of the corresponding filter type. The struct should be created using the new() function of the filter type.
    The struct takes 3 arguments, the field the filter should act on, a key referencing the filter(to be used in the url), and a map of options which will contain more info about the filter.

    As a general rule of thumb, the field should be the name of the field as an atom(in case of a normal field) or a tuple containing the table name and the field name(in case of an associated field).

    A detailed guide for defining each type of filter has been provided in its corresponding module.

  ## License

    MIT License. See LICENSE file for details.

  ## Contributing

    1. Fork the repository
    2. Create your feature branch (`git checkout -b feature/amazing-feature`)
    3. Commit your changes (`git commit -m 'Add amazing feature'`)
    4. Push to the branch (`git push origin feature/amazing-feature`)
    5. Open a Pull Request

  """
end

## Agent

**Use Tool: read_file (toolu_vrtx_01Dd12pipjaj386QdQA2hYaL)**
```json
{
  "path": "live_table/fields.md"
}
```

**Tool Results: toolu_vrtx_01Dd12pipjaj386QdQA2hYaL**

# Fields

Fields represent the columns defined for a LiveTable. They are configured using the `fields()` function in the LiveView where LiveResource is called.

## Configuration

The `fields()` function should return a keyword list where each key represents a field and maps to configuration options for that field.

### Example
```elixir
def fields() do
  [
    id: %{
      label: "ID",
      sortable: true,
      searchable: false
    }
  ]
end
```

## Field Options

Each field accepts the following options in its configuration map:

* [`label`](#label) (string, required)
* [`sortable`](#sortable) (boolean, required)
* [`searchable`](#searchable) (boolean, required)
* [`assoc`](#assoc) (tuple, optional)
* [`renderer`](#renderer) (function, optional)
* [`computed`](#computed) (dynamic query, required)

### Label
Defines the column header text that will appear in:
- The rendered HTML table
- Exported CSV & PDF files

This label acts as the human-readable name for the column across all formats.

#### Examples
```elixir
# Basic label
quantity: %{
  label: "Stock Quantity"
}

# Price with currency label
price: %{
  label: "Price (USD)"
}
```

### Sortable
Defines if the column can be sorted by the user. Renders an arrow in the column header for a sortable column if its included in the sorted columns.

#### Examples
```elixir
# Basic numeric sorting
id: %{
  label: "ID",
  sortable: true
}

# Date field sorting
created_at: %{
  label: "Created Date",
  sortable: true
}
```

> **Note**: By default, multi-column sort is available on all tables. All columns with `sortable: true` can be sorted under multi-sort. **Hold `Shift` while clicking on the column headers to add the column to your sort order.**


### Searchable
Defines if the column can be searched by full text search from the search bar. Text matching is done by the ilike operator and includes letters in the middle of the word as well.

#### Examples
```elixir
# Basic text search
username: %{
  label: "Username",
  searchable: true
}

# Email search
email: %{
  label: "Email Address",
  searchable: true
}
```

### Assoc
Used to define associated fields for the list of columns. Expects a tuple of the form `{table_name, field_name}`.

#### Examples
```elixir
# Basic one-to-one association
supplier_name: %{
  label: "Supplier Name",
  assoc: {:suppliers, :name},
  searchable: false,
  sortable: false
}
```

From this point on, the table will be joined to the base schema, and is aliased under `table_name`. Base schema will be aliased as `resource`

> **Note**: It is important to remember the order in which each table is joined to the base schema, as the same order needs to be followed to alias the fields with dynamic(). LiveTable joins tables in the same order in which they were defined in the fields.

### Renderer
Defines the function component to use for rendering each cell. Useful when we want to display stored data in a different, more legible format.

#### Examples
```elixir
# Boolean status renderer
active: %{
  label: "Active",
  renderer: &active?/1
}

# Custom price formatter
price: %{
  label: "Price",
  renderer: &format_price/1
}

# Complex status with multiple states
status: %{
  label: "Order Status",
  renderer: &order_status/1
}
```

```elixir
# Example renderer implementations
def active?(true = assigns) do
  ~H"""
  <span class="px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded-full">
    {assigns}
  </span>
  """
end

def format_price(price) do
  ~H"""
  <span class="font-mono">
    <%= Number.Currency.number_to_currency(@price) %>
  </span>
  """
end

def order_status(status) do
  ~H"""
  <%= case @status do %>
    <% "pending" -> %>
      <span class="text-yellow-600">⏳ Pending</span>
    <% "processing" -> %>
      <span class="text-blue-600">⚙️ Processing</span>
    <% "completed" -> %>
      <span class="text-green-600">✅ Completed</span>
  <% end %>
  """
end
```

### Computed
Defines computed fields, which are calculated on the fly from the database. Used to render columns like tax or amount, which are not stored as a column in the database, or which change based on existing data.

Takes a dynamic query expression, using fragment to define the function.

#### Examples
```elixir
# Basic multiplication
total_value: %{
  label: "Total Value",
  sortable: true,
  computed: dynamic([resource: p], fragment("? * ?", p.price, p.stock_quantity))
}
```

> **Note**: When working with associated fields, it is important to remember the order in which each table is joined to the base schema, as the same order needs to be followed to alias the fields with dynamic(). LiveTable joins tables in the same order in which they were defined in the fields.

## Normal Fields
These are fields belonging to the base schema. **The `key` should be the name of the field in the base schema.**

#### Examples
```elixir
# where my base schema ontains id, name, email fields
def fields() do
  [
  id: %{label: "ID", sortable: true},
  name: %{label: "Name", sortable: true, searchable: true},
  email: %{label: "Email", sortable: true, searchable: true},
  ]
end
```

## Joined/Associated Fields
These are associated fields. They belong to tables with relations to the base schema. They should be specified using the `assoc` key, which takes a tuple of the form `{:table_name, :field}`.

Be it any type of relation, it can be defined using the `assoc` keyword. Under the hood, LiveTable uses the `left_join` to join tables with the foreign key of id.

* *Currently, nested relations are not supported*

Here, the key can be anything - as long as its a valid atom. But choose something appropriate as its used to reference the field in the URL params.

#### Examples

```elixir
image: %{
  label: "Image",
  sortable: false,
  searchable: false,
  assoc: {:image, :url}
},
supplier_description: %{
  label: "Supplier Email",
  assoc: {:suppliers, :contact_info},
  searchable: false,
  sortable: true
},
category_name: %{
  label: "Category Name",
  assoc: {:category, :name},
  searchable: false,
  sortable: false
},
```

## Computed Fields
These are fields computed from preexisting fields in the database. They're to be defined using the [`computed`](#computed) key word.

When using associated fields in `dynamic`, remember to alias them in the same order in which fields were joined using `assoc`. `resoource` refers to the base schema.

```elixir
# Complex calculation with multiple conditions
profit_margin: %{
  label: "Profit Margin %",
  sortable: true,
  computed:
    dynamic(
      [resource: p],
      fragment(
        "CASE WHEN ? > 0 THEN ((? - ?) / ?) * 100 ELSE 0 END",
        p.selling_price,
        p.selling_price,
        p.cost_price,
        p.selling_price
      )
    )
}
```

If a table has not already been joined, it can be joined in the same field using `assoc`.

#### Examples

```elixir
# Count of associated records
supplier_count: %{
  label: "Supplier Count",
  sortable: true,
  assoc: {:suppliers, :name},
  computed:
    dynamic(
      [resource: p, suppliers: s],
      fragment("(SELECT COUNT(*) FROM products_suppliers WHERE product_id = ?)", p.id)
    )
}
```

## Agent

**Use Tool: read_file (toolu_vrtx_015jBUV6xrsYwyhZERyQyBFk)**
```json
{
  "path": "live_table/filters.md"
}
```

**Tool Results: toolu_vrtx_015jBUV6xrsYwyhZERyQyBFk**

# Filters
Filters allow us to add interactive filtering capabilities to LiveTable. They are configured using the `filters()` function in the LiveView where LiveResource is called.

## Configuration
The `filters()` function should return a keyword list where each key represents a filter and maps to its configuration.

### Examples
```elixir
def filters do
  [
    active: Boolean.new(:active, "active", %{
      label: "Active Products Only",
      condition: dynamic([p], p.active == true),

      temperature:
        Range.new(:temperature, "temp_range", %{
          type: :number,
          label: "Temperature Range",
          unit: "°C",
          min: 0,
          max: 50,
          default_min: 10,
          default_max: 40,
          step: 1
        })
    }),

    category:
      Select.new({:category, :name}, "category", %{
        label: "Category",
        options_source: {Catalog, :search_categories, []}
      })
  ]
end
```

## Filter Types
LiveTable supports 3 types of filters.

* [`Boolean`](#boolean)
* [`Select`](#select)
* [`Range`](#range)

Each filter has its own struct defined in its module. Each struct takes the `field`, `key`, and an `options` map.

Creation of a filter can be done using the `new/3` function, which takes the `field`, `key`, and `options`.

Similar to fields, the `field` key can take an atom(in case of a normal field to filter on), or a tuple of the form `{:table_name, field}`(to filter by an associated field).

An added bonus of defining the field separately is- a particular field need not be displayed in the table, and you can still filter by it.


### Boolean
Boolean filters are used for true/false conditions. They render as checkboxes in the UI. They take a dynamic query fragment, which the checkbox toggles on or off.

As an extension, any dynamic query condition can be passed, and the checkboxes used to toggle it.

A detailed guide on boolean filters is available at `LiveTable.Boolean`


### Range
Range filters allow filtering numeric values within a specified range. They support

* `number` (Integers & Floats)
* `date`
* `datetime`

The sliders can be adjusted to filter by the required range, and persist their state from URL params.

A detailed guide on range filters is available at `LiveTable.Range`


### Select
Select filters provide dropdown selection capabilities with static and dynamic options.

Static options are a set of predefined values. Dynamic options can be fetched from the database or any other source depending on the typed input by the user.

Select filter also allows for custom styling of the options from templates.

A detailed guide on select filters is available at `LiveTable.Select`

## Agent

**Use Tool: read_file (toolu_vrtx_01MEskkPDxE1YNoWDRDCDcLY)**
```json
{
  "path": "live_table/exports.md"
}
```

**Tool Results: toolu_vrtx_01MEskkPDxE1YNoWDRDCDcLY**

# Exports
## Export Support

LiveTable supports both CSV and PDF exports with background processing.
It uses Oban to handle bakground jobs, so that export file can be prepared without hanging the LiveView.

- CSV exports are handled by [`LiveTable.CsvGenerator`](https://github.com/gurujada/live_table/blob/master/lib/live_table/csv_generator.ex).
  Makes use of [`NimbleCSV`](https://hex.pm/packages/nimble_csv) under the hood.
- PDF exports use [`Typst`](https://typst.app/universe) for formatting and generation. Handled by [`LiveTable.PdfGenerator`](https://github.com/gurujada/live_table/blob/master/lib/live_table/pdf_generator.ex)

The headers are the same as that rendered by the table. By default, all records are exported without pagination.

Records are streamed inside of a [`Repo.transaction/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:transaction/2) function using [`Repo.stream/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:stream/2),
so that no more than a 1000 records are loaded into memory at a time.
This makes it extremely efficient and blazing fast for exporting large datasets, all the while remaining scalable.

## Configuration
### Oban
LiveTable uses Oban to spawn background jobs that prepare the file without hanging the current liveview.
For small installtions that don't use exports, Oban configuration can be ignored.

Configure the Oban instance and queues in `config.exs`:

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
ObanWeb can be configured in the router to monitor background jobs.

  ```elixir
  # lib/your_app_web/router.ex
  import Oban.Web.Router

  scope "/", YouAppWeb do
    # your other routes
    oban_dashboard("/oban")
  end
  ```

> **Note**: Remember to add exports to the list of allowed static paths in `lib/yourapp_web.ex`

```elixir
def static_paths, do: ~w(assets fonts images favicon.ico exports robots.txt)
```


## CSV Exports
LiveTable uses [`NimbleCSV`](https://hex.pm/packages/nimble_csv) with Oban for handling CSV exports.


## PDF Exports
LiveTable uses [`Typst`](https://typst.app/universe) with Oban for handling PDF exports.
Typst is a Rust based typesetting engine that generates PDFs from .typ files
This makes it extremely fast and well suited to handle large datasets.


> **Note**: LiveTable uses `System.cmd/2` to compile the .typ file into a PDF. Ensure that `typst` is installed in your system.

Make sure `exports: true` is set in table configuration options.

## Agent

**Use Tool: read_file (toolu_vrtx_01CqQF7AWQ8TjR6QYvHNZDav)**
```json
{
  "path": "live_table/table_config.md"
}
```

**Tool Results: toolu_vrtx_01CqQF7AWQ8TjR6QYvHNZDav**

# Table Configuration
LiveTable offers configuration options for each table.

They change the basic behaviour of the table - default sort order, default sort by, turning pagination on and off, specifiying options for select in pagination etc, all these can be changed under table configuration.


These configuration options are defined in 3 levels, **each subsequent level taking precedence over the latter**.

1. [**Default LiveTable options**](#1-livetable-default-options)
2. [**Application-wide defaults**](#2-application-wide-defaults)
3. [**Individual table options**](#3-individual-table-options)

## Configuration Levels

### 1. LiveTable Default Options

These are the built-in options defined by LiveTable:

```elixir
%{
  pagination: %{
    enabled: true,
    sizes: [10, 25, 50]
  },
  sorting: %{
    enabled: true,
    default_sort: [id: :asc]
  },
  exports: %{
    enabled: true,
    formats: [:csv, :pdf]
  },
  search: %{
    debounce: 300
  }
}
```

### 2. Application-Wide Defaults

LiveTable's defaults can be overridden for the entire application in `config.exs`:

```elixir
config :live_table,
  defaults: %{
    pagination: %{
      enabled: true,
      sizes: [20, 50, 100]  # Custom page sizes
    },
    sorting: %{
      enabled: true,
      default_sort: [inserted_at: :desc]  # Changed default sort
    }
  }
```
Only the options to be changed can be specified. LiveTable is smart enough to keep the other options as is, overriding the changes.

### 3. Individual Table Options
For case specific changes, options can be changed by implementing the `table_options/0` function in the corresponding LiveView:

```elixir
defmodule MyAppWeb.UserLive.Index do
  use MyAppWeb, :live_view
  use LiveTable.LiveResource, schema: User, resource: "users"
  # ... fields and filters

  def table_options do
    %{
      pagination: %{
        enabled: true,      # Turns pagination on and off
        sizes: [5, 10, 25]  # Custom sizes for this table only
      },
      exports: %{
        enabled: false  # Disable exports for this table
      }
    }
  end
end
```
Only the options to be overridden need to be specified.

## Configuration Options

### Pagination Options
- `enabled` (boolean): Enables/disables pagination
- `sizes` (list): Available page size options

```elixir
%{
  pagination: %{
    enabled: true,
    sizes: [10, 25, 50]
  }
}
```

### Sorting Options
- `enabled` (boolean): Enables/disables sorting
- `default_sort` (keyword list): Default sort field and direction

```elixir
%{
  sorting: %{
    enabled: true,
    default_sort: [id: :asc]
  }
}
```
A list of key value pairs like `[id: asc, inserted_at: desc]` can be given to sort by multiple sort orders by default.

### Export Options
- `enabled` (boolean): Enables/disables export functionality
- `formats` (list): Available export formats (`:csv` and/or `:pdf`)

```elixir
%{
  exports: %{
    enabled: true,
    formats: [:csv, :pdf]
  }
}
```

### Search Options
- `debounce` (integer): Debounce time in milliseconds for search input

```elixir
%{
  search: %{
    debounce: 300
  }
}
```

## Examples

### Minimal Configuration
```elixir
# No configuration needed - uses all defaults
defmodule MyAppWeb.UserLive.Index do
  use MyAppWeb, :live_view
  use LiveTable.LiveResource, schema: User, resource: "users"
end
```

### Custom Application Defaults
```elixir
# config/config.exs
config :live_table,
  defaults: %{
    pagination: %{
      enabled: true,
      page_size: 15,
      sizes: [15, 30, 50]
    },
    sorting: %{
      enabled: true,
      default_sort: [inserted_at: :desc]
    },
    exports: %{
      enabled: false
    }
  }
```

### Table-Specific Configuration
```elixir
defmodule MyAppWeb.ProductLive.Index do
  use MyAppWeb, :live_view
  use LiveTable.LiveResource, schema: Product, resource: "products"

  def table_options do
    %{
      pagination: %{
        enabled: true,
        page_size: 50,
        sizes: [50, 100, 200]
      },
      sorting: %{
        enabled: true,
        default_sort: [price: :desc]
      },
      exports: %{
        enabled: true,
        formats: [:csv]  # Only allow CSV export
      }
    }
  end
end
```

> **Note** Setting the `per_page` limit beyond 50 is generally discouraged. A degradation in perforance and latency is observed. For this reason, LiveTable does not allow greater than 50 records per page.


## Custom Components
In several places, LiveTable makes use of components like checkbox inputs and icons. These components were borrowed from the `CoreComponents` of Phoenix LiveView. They can be previewed [here](https://github.com/gurujada/live_table/blob/master/lib/live_table/components.ex)

However, they can be customized as well.

In the `confix.exs` file where LiveTable is configured, a `components` key can be passed, pointing to a module containing the custom components.

### Examples

```elixir
# config/config.exs
config :live_table,
  components: MyApp.CustomComponents
```

## Agent

**Use Tool: read_file (toolu_vrtx_014YbgNJC1ShvFArJADo6DsZ)**
```json
{
  "path": "live_table/lib/live_table/live_resource.ex"
}
```

**Tool Results: toolu_vrtx_014YbgNJC1ShvFArJADo6DsZ**

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

      def list_resources(fields, options, _, {module, function, args} = data_provider)
          when is_atom(function) do
        filters = Map.get(options, "filters", nil)

        apply(module, function, args)
        |> join_associations(filters)
        |> apply_filters(filters, fields)
        |> maybe_sort(fields, options["sort"]["sort_params"], options["sort"]["sortable?"])
        |> maybe_paginate(options["pagination"], options["pagination"]["paginate?"])
      end

      def list_resources(fields, options, schema, nil) do
        filters = Map.get(options, "filters", nil)

        schema
        |> from(as: :resource)
        |> join_associations(filters)
        |> select_columns(fields)
        |> apply_filters(filters, fields)
        |> maybe_sort(fields, options["sort"]["sort_params"], options["sort"]["sortable?"])
        |> maybe_paginate(options["pagination"], options["pagination"]["paginate?"])
      end

      def stream_resources(fields, %{"pagination" => %{"paginate?" => true}} = options, nil) do
        per_page = options["pagination"]["per_page"] |> String.to_integer()

        schema = @resource_opts[:schema]

        list_resources(fields, options, schema, nil)
        |> @repo.all()
        |> Enum.split(per_page)
      end

      def stream_resources(fields, %{"pagination" => %{"paginate?" => false}} = options, nil) do
        schema = @resource_opts[:schema]
        list_resources(fields, options, schema, nil) |> @repo.all()
      end

      def stream_resources(
            fields,
            %{"pagination" => %{"paginate?" => true}} = options,
            data_provider
          )
          when not is_nil(data_provider) do
        per_page = options["pagination"]["per_page"] |> String.to_integer()

        schema = @resource_opts[:schema]

        list_resources(fields, options, schema, data_provider)
        |> @repo.all()
        |> Enum.split(per_page)
      end

      def stream_resources(
            fields,
            %{"pagination" => %{"paginate?" => false}} = options,
            data_provider
          )
          when not is_nil(data_provider) do
        schema = @resource_opts[:schema]
        list_resources(fields, options, schema, data_provider) |> @repo.all()
      end

      def get_merged_table_options do
        TableConfig.get_table_options(table_options())
      end
    end
  end
end

## Agent

**Use Tool: list_directory (toolu_vrtx_01TGKT2SgKLmj7hdHhLwLxzf)**
```json
{
  "path": "live_table/lib/live_table/workers"
}
```

**Tool Results: toolu_vrtx_01TGKT2SgKLmj7hdHhLwLxzf**

live_table/lib/live_table/workers/csv_worker.ex
live_table/lib/live_table/workers/pdf_worker.ex

## Agent

**Use Tool: grep (toolu_vrtx_01AsB34nQN6GXqMDVsUfN5hB)**
```json
{
  "regex": "defmodule.*\\.new",
  "include_pattern": "**/*.ex"
}
```

**Tool Results: toolu_vrtx_01AsB34nQN6GXqMDVsUfN5hB**

No matches found
## Agent

**Use Tool: grep (toolu_vrtx_01YTn2ux6oVCJC7gaQdgtffL)**
```json
{
  "include_pattern": "**/*.ex",
  "regex": "def new\\("
}
```

**Tool Results: toolu_vrtx_01YTn2ux6oVCJC7gaQdgtffL**

Found 3 matches:

## Matches in live_table/lib/live_table/boolean.ex

### defmodule LiveTable.Boolean › def new › L76-80
```

  @doc false
  def new(field, key, options) do
    %__MODULE__{field: field, key: key, options: options}
  end
```

## Matches in live_table/lib/live_table/range.ex

### defmodule LiveTable.Range › def new › L174-178
```

  @doc false
  def new(field, key, options) do
    type = Map.get(options, :type, :number)
    type_defaults = Map.get(@type_defaults, type)
```

## Matches in live_table/lib/live_table/select.ex

### defmodule LiveTable.Select › def new › L166-170
```

  @doc false
  def new(field, key, options) do
    complete_options = Map.merge(@default_options, options)
    %__MODULE__{field: field, key: key, options: complete_options}
```

## Agent

**Use Tool: read_file (toolu_vrtx_01NspXiobLo2y1cpk19EiF9K)**
```json
{
  "path": "live_table/lib/live_table/boolean.ex"
}
```

**Tool Results: toolu_vrtx_01NspXiobLo2y1cpk19EiF9K**

defmodule LiveTable.Boolean do
  @moduledoc """
    A module for handling boolean (checkbox) filters in LiveTable.

    This module provides functionality for creating and managing boolean filters implemented
    as checkboxes in the LiveTable interface. It's designed to handle simple true/false and even complex
    filtering scenarios with customizable options and conditions.

    Similar to all filters in LiveTable, Boolean filters can be created using the `new/3` function,
    which takes the `key`, `field`, and an `options` map.
    The key will be used to reference the filter in the URL params.


  ### Options map
  The boolean filter accepts the following arguments in the options map:
  - `:label` - The text label displayed next to the checkbox
  - `:condition` - The Ecto query condition to be applied when the checkbox is checked (a dynamic query)
  - `:class` - Optional CSS classes for the checkbox

  ## Examples
  ```elixir
  # Creating a basic boolean filter for active status
  Boolean.new(:active, "active_filter", %{
    label: "Show Active Only",
    condition: dynamic([p], p.active == true)
  })

  # Creating a boolean filter with a complex condition
  Boolean.new(:premium, "premium_filter", %{
    label: "Premium Users",
    condition: dynamic([p], p.subscription_level == "premium" and p.active == true)
  })

  # Creating a boolean filter for any toggleable condition
  Boolean.new(:premium, "premium_filter", %{
    label: "Greater than 50$",
    condition: dynamic([p], p.price > 50)
  })
  ```
  Since the condition is a dynamic query, a condition using joined fields can be given.
  ```elixir
  Boolean.new(
    :supplier_email,
    "supplier",
    %{
      label: "Email",
      condition: dynamic([p, s], s.contact_info == "procurement@autopartsdirect.com")
    }
  )
  ```
  > **Note**: Remember to use aliases in the same order in which they were defined in `fields()`.


  If an associated field is not defined in the `fields()` function, and a boolean filter needs to be applied,
  a tuple containing `{:table_name, field}` can be passed as the field and can be
  aliased using the `table_name` in `dynamic`

  ```elixir
  Boolean.new(
    {:suppliers, :email},
    "supplier",
    %{
      label: "Email",
      condition: dynamic([p, s], s.contact_info == "procurement@autopartsdirect.com")
    }
  )
  ```

  """

  import Ecto.Query
  import LiveTable.SortHelpers, only: [dynamic_component: 1]
  use Phoenix.Component

  defstruct [:field, :key, :options]

  @doc false
  def new(field, key, options) do
    %__MODULE__{field: field, key: key, options: options}
  end

  @doc false
  def apply(acc, %__MODULE__{options: %{condition: condition}}) do
    dynamic(^acc and ^condition)
  end

  @doc false
  def render(assigns) do
    components_module = Application.get_env(:live_table, :components, LiveTable.Components)

    assigns = Map.put(assigns, :components_module, components_module)

    ~H"""
    <.dynamic_component
      module={@components_module}
      function={:input}
      type="checkbox"
      name={"filters[#{@key}]"}
      label={@filter.options.label}
      checked={Map.has_key?(@applied_filters, @key) || Map.get(@filter.options, :default)}
    />
    """
  end
end

## Agent

**Use Tool: read_file (toolu_vrtx_019QZUisxhqHekanD9sZaDWk)**
```json
{
  "path": "live_table/lib/live_table/range.ex"
}
```

**Tool Results: toolu_vrtx_019QZUisxhqHekanD9sZaDWk**

defmodule LiveTable.Range do
  @moduledoc """
  A module for handling range-based filters in LiveTable.

  This module provides functionality for creating and managing range filters that can handle
  numeric values, dates, and datetimes. It supports creating range sliders with customizable
  options and appearances.

  Makes use of nouislider under the hood for creating the range slider.
  See the [noUiSlider documentation](https://refreshless.com/nouislider/) for more details
  on customizing the slider behavior and appearance.

  > **Note**: Requires the TableHooks to be imported in your app.js

  ## Options
  The module accepts the following options:
  - `:type` - The type of range filter (`:number`, `:date`, or `:datetime`)
  - `:label` - The label text for the range filter
  - `:unit` - The unit to display after the label (optional)
  - `:css_classes` - CSS classes for the main container
  - `:slider_classes` - CSS classes for the slider element
  - `:label_classes` - CSS classes for the label element

  For default values, see: [LiveTable.Range source code](https://github.com/gurujada/live_table/blob/master/lib/live_table/range.ex)

  ## Types Support
  The module supports three types of range filters:
  - `:number` - For numeric ranges
  - `:date` - For date ranges
  - `:datetime` - For datetime ranges


  ### :number
  For numeric ranges with configurable min, max and step values:

  ```elixir
  Range.new(:price, "price_range", %{
    type: :number,
    label: "Price",
    default_min: 0,
    default_max: 1000,
    step: 10
  })
  # Renders a range filter with from 0 to 1000 with a step of 10.
  ```

  ### :date
  For date ranges with customizable date boundaries:

  ```elixir
  Range.new(:created_at, "date_range", %{
    type: :date,
    label: "Creation Date",
    default_min: ~D[2024-01-01],
    default_max: ~D[2024-12-31]
  })
  # Renders a date range filter with dates from 2024-01-01 to 2024-12-31.
  ```

  ### :datetime
  For datetime ranges with configurable datetime boundaries:

  ```elixir
  Range.new(:updated_at, "datetime_range", %{
    type: :datetime,
    label: "Last Updated",
    default_min: ~N[2024-01-01 00:00:00],
    default_max: ~N[2024-12-31 23:59:59],
    step: 3600 # Step in seconds
  })
  # Renders a datetime range filter with dates from 2024-01-01 00:00:00 to 2024-12-31 23:59:59.
  # Remember to pass the datetime values in `NaiveDateTime` format.
  ```

  ## Examples

  ```elixir
  # Creating a numeric range filter
  Range.new(:price, "price_range", %{
    type: :number,
    label: "Price Range",
    unit: "$",
    min: 0,
    max: 1000,
    step: 10
  })

  # Creating a date range filter
  Range.new(:created_at, "date_range", %{
    type: :date,
    label: "Date Range",
    min: ~D[2024-01-01],
    max: ~D[2024-12-31]
  })
  ```
  If you want to use the range filter with a joined schema, you can pass the field as a tuple, with the table name and the field-
  ```elixir
  Range.new({:suppliers, :created_at}, "created_at", %{
    type: :date,
    label: "Supplier Creation",
    min: ~D[2024-01-01],
    max: ~D[2024-12-31],
  })
  ```
  """

  import Ecto.Query
  use Phoenix.Component
  import LiveTable.TableConfig, only: [deep_merge: 2]

  defstruct [:field, :key, :options]

  @today Date.utc_today()
  @now DateTime.utc_now()
  @type_defaults %{
    number: %{
      min: 0,
      max: 100,
      step: 1,
      default_min: 0,
      default_max: 100,
      current_min: nil,
      current_max: nil,
      pips_mode: "positions",
      pips_values: [0, 25, 50, 75, 100],
      pips_density: 4,
      pips_stepped: true
    },
    date: %{
      min: Date.add(@today, -1),
      max: Date.add(@today, 1),
      step: 1,
      default_min: Date.add(@today, -1),
      default_max: Date.add(@today, 1),
      current_min: nil,
      current_max: nil,
      pips_mode: "count",
      # weekly markers
      pips_density: 3,
      pips_stepped: true,
      pips_values: [Date.add(@today, -7), Date.add(@today, 0), Date.add(@today, 7)]
    },
    datetime: %{
      min: DateTime.add(@now, -24 * 3600),
      max: DateTime.add(@now, 24 * 3600),
      default_min: DateTime.add(@now, -24 * 3600),
      default_max: DateTime.add(@now, 24 * 3600),
      current_min: nil,
      current_max: nil,
      step: 3600,
      pips_mode: "count",
      # hourly markers
      pips_density: 2,
      pips_stepped: true,
      pips_values: [DateTime.add(@now, -3600), DateTime.add(@now, 0), DateTime.add(@now, 3600)]
    }
  }

  @default_options %{
    type: :number,
    label: "Range",
    pips: false,
    unit: "",
    css_classes: "w-full p-3 card card-bordered bg-base-100",
    slider_classes: "w-full h-2 mt-6 mb-2",
    label_classes: "label-text text-sm font-medium mb-2",
    event_type: "change",
    slider_options: %{
      tooltips: true,
      padding: 0,
      behaviour: "drag"
    }
  }

  @doc false
  def new(field, key, options) do
    type = Map.get(options, :type, :number)
    type_defaults = Map.get(@type_defaults, type)

    complete_options =
      @default_options
      |> deep_merge(type_defaults)
      |> deep_merge(options)
      |> Map.put(:type, type)

    %__MODULE__{field: field, key: key, options: complete_options}
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :number} = options}) do
    {min_value, max_value} = get_min_max(options)

    dynamic(
      [{^table, t}],
      ^acc and fragment("? BETWEEN ? AND ?", field(t, ^field), ^min_value, ^max_value)
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: field, options: %{type: :number} = options})
      when is_atom(field) do
    {min_value, max_value} = get_min_max(options)
    dynamic([p], ^acc and fragment("? BETWEEN ? AND ?", field(p, ^field), ^min_value, ^max_value))
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :date} = options}) do
    {min_value, max_value} = get_min_max(options)

    dynamic(
      [{^table, t}],
      ^acc and
        fragment(
          "? BETWEEN ? AND ?",
          fragment("DATE(?)", field(t, ^field)),
          type(^min_value, :date),
          type(^max_value, :date)
        )
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: field, options: %{type: :date} = options}) do
    {min_value, max_value} = get_min_max(options)

    dynamic(
      [p],
      ^acc and
        fragment(
          "? BETWEEN ? AND ?",
          fragment("DATE(?)", field(p, ^field)),
          type(^min_value, :date),
          type(^max_value, :date)
        )
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, field}, options: %{type: :datetime} = options}) do
    {min_value, max_value} = get_min_max(options)

    dynamic(
      [{^table, t}],
      ^acc and fragment("? BETWEEN ? AND ?", field(t, ^field), ^min_value, ^max_value)
    )
  end

  @doc false
  def apply(acc, %__MODULE__{field: field, options: %{type: :datetime} = options}) do
    {min_value, max_value} = get_min_max(options)
    dynamic([p], ^acc and fragment("? BETWEEN ? AND ?", field(p, ^field), ^min_value, ^max_value))
  end

  defp format_value(:number, value), do: value
  defp format_value(:date, nil), do: nil
  defp format_value(:date, value), do: Date.to_iso8601(value)

  defp format_value(:datetime, nil), do: nil

  defp format_value(:datetime, value) do
    value
    |> NaiveDateTime.to_iso8601()
    |> String.replace(" ", "T")
  end

  @doc false
  def render(assigns) do
    {current_min, current_max} = get_current_min_max(assigns.applied_filters, assigns.key)
    assigns = Map.put(assigns, :current_min, current_min) |> Map.put(:current_max, current_max)

    ~H"""
    <div class={@filter.options.css_classes}>
      <label class={@filter.options.label_classes}>
        {@filter.options.label}
        {if @filter.options.unit != "", do: " (#{@filter.options.unit})"}
      </label>
      <div
        id={"range_filter[#{@key}]"}
        phx-hook="RangeSlider"
        phx-update="ignore"
        data-key={@key}
        data-type={@filter.options.type}
        data-min={format_value(@filter.options.type, @filter.options.min)}
        data-max={format_value(@filter.options.type, @filter.options.max)}
        data-default-min={format_value(@filter.options.type, @filter.options.default_min)}
        data-default-max={format_value(@filter.options.type, @filter.options.default_max)}
        data-current-min={format_value(@filter.options.type, @current_min)}
        data-current-max={format_value(@filter.options.type, @current_max)}
        data-event-type={@filter.options.event_type}
        data-pips={Jason.encode!(@filter.options.pips)}
        data-pips-mode={@filter.options.pips_mode}
        data-pips-values={Jason.encode!(@filter.options.pips_values)}
        data-pips-density={@filter.options.pips_density}
        data-pips-stepped={if @filter.options.pips_stepped, do: "true", else: "false"}
        data-step={@filter.options.step}
        data-tooltips={Jason.encode!(@filter.options.slider_options.tooltips)}
        data-padding={Jason.encode!(@filter.options.slider_options.padding)}
        class={@filter.options.slider_classes}
      >
        <div id={"slider[#{@key}]"} class="slider-target"></div>
      </div>
    </div>
    """
  end

  defp get_current_min_max(applied_filters, key) do
    case Map.get(applied_filters, key) do
      nil -> {nil, nil}
      %{options: %{current_min: min, current_max: max}} -> {min, max}
    end
  end

  defp get_min_max(options) do
    min = Map.get(options, :current_min, options.default_min)
    max = Map.get(options, :current_max, options.default_max)
    {min, max}
  end
end

## Agent

**Use Tool: read_file (toolu_vrtx_01SD9HyTfPaXnJDj6bqxh3vD)**
```json
{
  "path": "live_table/lib/live_table/select.ex"
}
```

**Tool Results: toolu_vrtx_01SD9HyTfPaXnJDj6bqxh3vD**

defmodule LiveTable.Select do
  @moduledoc """
    A module for handling select-based filters in LiveTable.

    This module provides functionality for creating and managing select filters that can handle
    single or multiple selections. It supports both static options and dynamic option loading,
    with customizable appearances and templates.


  ## Options

    The module accepts the following options:
    - `:label` - The label text for the select filter
    - `:options` - Static list of options for the select
    - `:options_source` - Function or module for dynamic option loading
    - `:option_template` - Custom template for rendering options
    - `:selected` - List of pre-selected values
    - `:loading_text` - Text to display while loading options
    - `:prompt` - Prompt text for the select
    - `:placeholder` - Placeholder text for the select
    - `:css_classes` - CSS classes for the main container
    - `:label_classes` - CSS classes for the label element
    - `:select_classes` - CSS classes for the select element

    For default values, see: [LiveTable.Select source code](https://github.com/gurujada/live_table/blob/master/lib/live_table/select.ex)

  ## Working with Options

    There are two ways to configure and display options in the select filter:

  ### 1. Static Options

    The simplest approach using a predefined list of options:

    ```elixir
    Select.new(:status, "status_select", %{
      label: "Status",
      options: [
        %{label: "Active", value: [1, "Currently active"]},
        %{label: "Pending", value: [2, "Awaiting processing"]},
        %{label: "Archived", value: [3, "No longer active"]}
      ]
    })
    ```

  ### 2. Dynamic Options via `options_source`

  Load options dynamically using a function or module. Used for fetching new options based on typed input.
  Uses `apply/3` under the hood to apply the function. Uses [`live-select-change`](https://github.com/gurujada/live_table/blob/master/lib/live_table/liveview_helpers.ex#L109) event to update the options.

    ```elixir
      # Point to your custom function
      Select.new({:suppliers, :name}, "supplier_name", %{
        label: "Supplier",
        options_source: {Demo.Catalog, :search_suppliers, []} # Same as you'd use for `apply/3`
      })

      # in your context module
      def search_suppliers(text) do
        Supplier
        |> where([c], ilike(c.name, ^"%\#{text}%"))
        |> select([c], {c.name, [c.id, c.contact_info]})
        |> Repo.all()
      end
    ```

    You could write your function to have other args passed to it as well. Just make sure the first arg is the text.
    It must return a tuple, with the first element being the label and the second being the value(or a list of fields).

  ## Option Templates

    You can provide custom templates for rendering options in two ways:
    1. Using the default template format for options with label and value pairs
    2. Providing a custom template function through the `:option_template` option

  ### Default Template

    The default template expects options in the format:
    ```elixir
    %{label: label, value: [id, description]}
    ```
    The default template can be seen at [git link](https://github.com/gurujada/live_table/blob/master/lib/live_table/select.ex#L211)

  ### Custom Template
    Custom templates can be provided as functions that take an option map and return rendered HTML:

    ```elixir
    def custom_template(option) do
      assigns = %{option: option}
      ~H\"\"\"
      <div class="flex flex-col">
        <span class="font-bold"><%= @option.label %></span> inas
        <span class="text-sm text-gray-500"><%= @option.value |> Enum.at(0) %></span>
      </div>
      \"\"\"
    end

    # in your filter definition
    Select.new({:suppliers, :name}, "supplier_name", %{
      label: "Supplier",
      placeholder: "Search for suppliers...",
      options_source: {Demo.Catalog, :search_suppliers, []}
      option_template: &custom_template/1
    })
    ```

    Each method can be combined with others - for example, you could use dynamic or static options with
    custom templates.


  ## Examples

  If the field you want to use is part of the base schema(given to `LiveResource`), you can simply pass the field name as an atom.
    ```elixir
    # Creating a basic select filter
    Select.new(:category, "category_select", %{
      label: "Category",
      options: [
        %{label: "Electronics", value: [1, "Electronics"]},
        %{label: "Books", value: [2, "Books"]}
      ]
    })
    ```

    If its part of a joined schema, you can pass it as a tuple, with the table name and field name as shown-
    ```elixir
    # Creating a select filter with options loaded from database
    Select.new({:suppliers, :name}, "supplier_name", %{
        label: "Supplier",
        options_source: {Demo.Catalog, :search_suppliers, []}
      })
    ```

    ```elixir
    # Advanced example with all options
    Select.new({:category, :name}, "category_name", %{
      label: "Category",
      placeholder: "Search for categories...",
      options_source: {Demo.Catalog, :search_categories, [\optional args\]}
      option_template: &custom_template/1,
    })
    ```

    Currently, nested relations are not supported.

  """
  import Ecto.Query
  import LiveSelect

  use Phoenix.Component
  defstruct [:field, :key, :options]

  @default_options %{
    label: "Select",
    options: [],
    options_source: nil,
    option_template: nil,
    selected: [],
    loading_text: "Loading options...",
    prompt: "Select an option",
    placeholder: "Select an option",
    css_classes: "w-full p-3 card card-bordered bg-base-100",
    label_classes: "label-text text-sm font-medium mb-2",
    select_classes: "mt-1 select select-bordered w-full !outline-none !ring-0 focus:!outline-none focus:!ring-0 focus:!border-base-300 hover:border-base-400"
  }

  @doc false
  def new(field, key, options) do
    complete_options = Map.merge(@default_options, options)
    %__MODULE__{field: field, key: key, options: complete_options}
  end

  @doc false
  def apply(acc, %__MODULE__{field: {table, _field}, options: %{selected: values}}) do
    dynamic([{^table, t}], ^acc and t.id in ^values)
  end

  # update to dynamically take primary key. not always id.
  @doc false
  def apply(acc, %__MODULE__{field: _field, options: %{selected: values}}) do
    dynamic([p], ^acc and p.id in ^values)
  end

  @doc false
  def render(assigns) do
    ~H"""
    <div id={"select_filter[#{@key}]"} class={@filter.options.css_classes}>
      <label class={@filter.options.label_classes}>
        {@filter.options.label}
      </label>
      <.live_select
        field={Phoenix.Component.to_form(%{})["filters[#{@key}]"]}
        id={"#{@key}"}
        placeholder={@filter.options.placeholder || @filter.options.prompt}
        dropdown_extra_class="max-h-60 overflow-y-scroll"
        text_input_class={@filter.options.select_classes}
        mode={:tags}
      >
        <:option :let={option}>
          {render_option_template(@filter.options.option_template, option)}
        </:option>
      </.live_select>
    </div>
    """
  end

  defp render_option_template(nil, %{label: label, value: [id, description]}) do
    assigns = %{label: label, id: id, description: description}

    ~H"""
    <span class="text-sm">{@label}</span>
    <br />
    <span class="text-xs opacity-60">{@id} in</span>
    <span class="text-xs opacity-60">{@description}</span>
    """
  end

  # Custom template provided as a function
  defp render_option_template(template_fn, option) do
    template_fn.(option)
  end
end

## Agent

**Use Tool: read_file (toolu_vrtx_01VUzfxQaFMWq1trN17kiYFy)**
```json
{
  "path": "live_table/context.md"
}
```

**Tool Results: toolu_vrtx_01VUzfxQaFMWq1trN17kiYFy**

Comprehensive Project Context

```markdown
# LiveTable Project - Current State & Next Steps

## Overview
LiveTable is a reusable Phoenix LiveView component for building data tables with sorting, pagination, filtering, and multiple view modes (table/card). It supports both auto-generated queries for simple cases and custom data providers for complex scenarios.

## Current Architecture

### Core Components
1. **LiveResource** - Main macro that provides table functionality
2. **TableComponent** - UI rendering (table and card modes)
3. **LiveViewHelpers** - Handles LiveView events and URL params
4. **TableConfig** - Configuration and defaults management

### Key Design Decisions Made

#### 1. Hybrid Data Approach ✅
- **Simple case**: Schema + basic fields → auto-generated queries
- **Complex case**: Custom data provider → full user control
- **Implementation**:
  ```elixir
  # Simple
  use LiveTable.LiveResource, schema: User

  # Complex
  use LiveTable.LiveResource  # No schema
  assign(socket, :dynamic_data_provider, {Context, :function, [args]})
  ```

#### 2. Field vs Filter Pattern ✅
- **Fields**: Either base schema fields OR custom query results (field keys must match query select keys)
- **Filters**: Always use `assoc: {:table_name, :field}` pattern for joins
- **Rationale**: Fields handle display, filters handle querying - different concerns

#### 3. Streams Only ✅
- **Decision**: Use Phoenix streams exclusively, no assigns fallback
- **Rationale**: Better performance, simpler codebase, no conditional complexity

#### 4. Multi-Mode Support ✅
- **Table mode**: Traditional rows/columns with sortable headers
- **Card mode**: Grid layout with custom user components
- **Sorting**: Table mode = column headers, Card mode = simple dropdown
- **Implementation**: Pattern matching in components, no if-else

### Current Implementation Status

#### ✅ Completed
1. **Basic LiveResource structure** - Macro with overridable functions
2. **Dynamic data providers** - `{module, function, args}` pattern
3. **Field configuration** - Labels, sorting, searching, rendering
4. **Filter system** - Boolean, Select, Range filters with auto-joins
5. **Table/Card mode switching** - Pattern-matched components
6. **Sorting for both modes** - Headers for table, dropdown for card
7. **Pagination** - With streams support
8. **Join logic** - Auto-joins for filters, user-controlled for display

#### 🚧 In Progress / Next Steps
1. **Custom header components** - Allow users to override header UI
2. **Filter join optimization** - Ensure no duplicate joins
3. **Documentation** - API docs and usage examples
4. **Error handling** - Better error messages for common mistakes

### Code Patterns & Conventions

#### ✅ Follow These Patterns
```elixir
# 1. Dynamic data provider
def mount(params, _session, socket) do
  socket = assign(socket, :dynamic_data_provider, {Context, :function, [id]})
  {:ok, socket}
end

# 2. Field keys match query select keys
def fields do
  %{
    program_name: %{label: "Program", sortable: true}  # Must match query
  }
end

# Query must return
select: %{program_name: p.name}  # Exact match

# 3. Pattern matching for modes
defp content_section(%{mode: :table} = assigns), do: # table view
defp content_section(%{mode: :card} = assigns), do: # card view

# 4. Filter associations
filters: %{
  supplier_name: Select.new({:suppliers, :name}, "supplier", %{
    condition: dynamic([r, suppliers: s], s.name == ^name)
  })
}
```

#### ❌ Avoid These Patterns
```elixir
# 1. Don't use assoc in field definitions anymore
fields: %{
  supplier_name: %{assoc: {:suppliers, :name}}  # ❌ Removed
}

# 2. Don't use conditional rendering in templates
<%= if @mode == :table do %>  # ❌ Use pattern matching instead

# 3. Don't mix simple and complex approaches
use LiveTable.LiveResource, schema: User, data_provider: {...}  # ❌ Pick one
```

### File Structure
```
live_table/
├── lib/live_table/
│   ├── live_resource.ex          # Main macro
│   ├── table_component.ex        # UI rendering
│   ├── live_view_helpers.ex      # Event handling
│   ├── table_config.ex           # Configuration
│   ├── sorting.ex                # Sort logic
│   ├── join.ex                   # Auto-join logic for filters
│   ├── filter.ex                 # Filter application
│   ├── paginate.ex               # Pagination logic
│   └── filters/
│       ├── boolean.ex            # Checkbox filters
│       ├── select.ex             # Dropdown filters
│       └── range.ex              # Range filters
```

### Current Challenges & Solutions

#### Challenge 1: Field-Filter Integration
**Problem**: Custom queries might not include all fields that filters reference
**Solution**: Auto-join logic in `join.ex` adds necessary joins for filters only

#### Challenge 2: Performance with Joins
**Problem**: Filters adding unnecessary joins
**Solution**: `Enum.uniq()` prevents duplicate joins, LEFT JOINs for optional filters

#### Challenge 3: User Learning Curve
**Problem**: Two different patterns (fields vs filters)
**Solution**: Clear documentation and examples showing when to use each

### Next Implementation Steps

#### 1. Custom Header Components (Priority 1)
```elixir
# Goal: Allow this
def table_options do
  %{
    custom_header: {MyAppWeb.JEEHeader, :render}
  }
end

# Implementation needed in TableComponent
defp header_section(assigns) do
  case get_in(assigns.table_options, [:custom_header]) do
    {module, function} -> apply(module, function, [prepare_header_assigns(assigns)])
    nil -> default_header_section(assigns)
  end
end
```

#### 2. Enhanced Documentation (Priority 2)
- Complete API documentation
- Migration guide from assoc-based fields
- Custom component examples
- Performance best practices

#### 3. Error Handling (Priority 3)
- Validate field keys match query select keys
- Better error messages for common mistakes
- Debugging helpers

#### 4. Testing Suite (Priority 4)
- Unit tests for each component
- Integration tests for full workflows
- Performance tests with large datasets

### Configuration Examples

#### Simple Table
```elixir
defmodule ProductsResource do
  use LiveTable.LiveResource, schema: Product

  def fields do
    %{
      name: %{label: "Name", sortable: true, searchable: true},
      price: %{label: "Price", sortable: true}
    }
  end
end
```

#### Complex Table with Custom Query
```elixir
defmodule CollegeProgramsResource do
  use LiveTable.LiveResource

  def mount(params, _session, socket) do
    college_id = extract_id(params)
    socket = assign(socket, :dynamic_data_provider, {Colleges, :list_programs, [college_id]})
    {:ok, socket}
  end

  def fields do
    %{
      program_name: %{label: "Program", sortable: true},
      opening_rank: %{label: "Opening Rank", sortable: true, assoc: {:rank_cutoff, :opening_rank}}
    }
  end

  def filters do
    %{
      category: Select.new({:rank_cutoff, :category}, "category", %{...})
    }
  end
end

# Context function
def list_programs(college_id) do
  from c in College,
    join: cp in CollegeProgram, on: cp.college_id == c.id,
    join: p in Program, on: p.id == cp.program_id,
    join: rc in RankCutoff, on: rc.college_program_id == cp.id, as: :rank_cutoff,
    where: c.id == ^college_id,
    select: %{
      program_name: p.name,      # Must match field key
      opening_rank: rc.opening_rank  # Must match field key
    }
end
```

#### Card Mode with Custom Component
```elixir
def table_options do
  %{
    mode: :card,
    card_component: &MyAppWeb.CollegeCard.card/1,
    card: %{grid_cols: 3, gap: 4}
  }
end

# Card component
defmodule MyAppWeb.CollegeCard do
  def card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <h3>{@record.program_name}</h3>
      <p>Opening Rank: {@record.opening_rank}</p>
    </div>
    """
  end
end
```

### Performance Considerations
- Use streams for all data (implemented)
- Minimize joins in custom queries
- Index frequently sorted/filtered columns
- Use LIMIT/OFFSET for pagination (implemented)

### Breaking Changes Made
1. Removed `assoc:` from field definitions
2. Changed to dynamic data provider assignment
3. Simplified to streams-only approach

This context document should be used for future development and helps maintain consistency in the codebase.
```

This comprehensive context covers everything we've discussed and decided. Use this as reference for future

## Agent

**Use Tool: thinking (toolu_vrtx_011UJRTh6gCEhwCu2BthDvNV)**
```json
{
  "content": "Now I have a comprehensive understanding of the LiveTable library. Let me analyze what I've learned:\n\n## Key Findings about LiveTable:\n\n### Current State:\n1. **Version**: Currently at 0.2.0 in mix.exs but README says 0.3.0 - this inconsistency needs addressing\n2. **Architecture**: Well-structured library with main components like LiveResource, TableComponent, filters (Boolean, Range, Select), sorting, pagination, and export functionality\n3. **Features**: \n   - Dynamic data tables with sorting, filtering, pagination\n   - Export to CSV and PDF (using Oban for background processing)\n   - Real-time updates via LiveView\n   - Multiple view modes (table/card)\n   - Advanced filtering system\n   - Multi-column sorting\n   - Join support for associated fields\n\n### Documentation Issues I Found:\n\n1. **Inconsistencies**: \n   - Version mismatch between mix.exs and README\n   - Some outdated information about field definitions using `assoc:`\n   - DaisyUI setup mentioned but not completely documented\n\n2. **Missing/Incomplete Documentation**:\n   - No comprehensive getting started guide\n   - Limited examples for complex use cases\n   - Configuration options scattered across different files\n   - Export setup (Typst installation) not clearly documented\n   - JavaScript hooks setup incomplete\n   - Migration guide missing for users upgrading\n\n3. **Structure Issues**:\n   - Documentation is spread across multiple .md files without clear navigation\n   - No clear hierarchy or learning path\n   - API reference missing\n   - Troubleshooting section missing\n\n4. **Technical Gaps**:\n   - Performance considerations not well documented\n   - Best practices missing\n   - Common pitfalls not addressed\n   - Testing setup not documented\n\nNow I need to create a comprehensive documentation plan that addresses these issues while making it developer-friendly, concise, and informative."
}
```

**Tool Results: toolu_vrtx_011UJRTh6gCEhwCu2BthDvNV**

Finished thinking.
## Agent

Based on my exploration of the LiveTable codebase, I can see this is a powerful and well-architected library for building real-time data tables in Phoenix LiveView. However, you're absolutely right - the documentation has several issues and gaps that make it difficult for developers to adopt and use effectively.

## Documentation Analysis

### Current Issues I Found:
1. **Version inconsistencies** (mix.exs shows 0.2.0, README claims 0.3.0)
2. **Scattered information** across multiple files without clear navigation
3. **Incomplete setup instructions** (missing Typst installation, partial JS setup)
4. **Outdated examples** (some still reference deprecated `assoc:` patterns)
5. **Missing crucial sections** (troubleshooting, best practices, migration guides)
6. **No clear learning progression** for different skill levels

## Proposed Documentation Plan

I propose restructuring the entire documentation into a logical, developer-friendly format:

### 1. **Main Documentation Structure**
```
├── README.md (Overview + Quick Start)
├── docs/
│   ├── installation.md
│   ├── quick-start.md
│   ├── configuration.md
│   ├── guides/
│   │   ├── basic-usage.md
│   │   ├── advanced-features.md
│   │   ├── custom-components.md
│   │   └── performance.md
│   ├── api/
│   │   ├── fields.md
│   │   ├── filters.md
│   │   ├── exports.md
│   │   └── table-options.md
│   ├── examples/
│   │   ├── simple-table.md
│   │   ├── complex-queries.md
│   │   └── real-world-scenarios.md
│   └── troubleshooting.md
```

### 2. **Content Strategy**

**Target Audience**: Elixir/Phoenix developers (beginner to advanced)
**Tone**: Professional, concise, example-driven
**Format**: Progressive disclosure (basic → advanced)

### 3. **Key Sections Planned**

#### A. **Installation & Setup** (Complete rewrite)
- Dependencies and requirements
- Step-by-step setup (Oban, CSS, JS, Typst)
- Verification steps
- Common setup issues

#### B. **Quick Start Guide** (New)
- 5-minute working example
- Basic table with sorting and filtering
- Clear copy-paste code blocks

#### C. **Configuration Guide** (Restructured)
- Application-level vs table-level options
- All available configuration options
- Real-world configuration examples

#### D. **API Reference** (Enhanced)
- Complete field options with examples
- All filter types with use cases
- Export configuration
- Table options reference

#### E. **Advanced Guides** (New)
- Custom data providers
- Complex joins and queries
- Performance optimization
- Custom renderers and components

#### F. **Examples & Recipes** (New)
- Common patterns
- Real-world scenarios
- Migration from other solutions

#### G. **Troubleshooting** (New)
- Common errors and solutions
- Performance issues
- Debugging tips

### 4. **Writing Principles**

1. **Show, don't just tell** - Every feature explained with working code examples
2. **Progressive complexity** - Start simple, build up to advanced features
3. **Copy-pasteable examples** - Code that actually works without modification
4. **Clear prerequisites** - What users need to know/have before each section
5. **Visual hierarchy** - Proper use of headings, code blocks, callouts
6. **Cross-references** - Link related concepts throughout

### 5. **Quality Standards**

- All code examples tested and working
- Consistent terminology throughout
- Clear callouts for warnings/tips/notes
- Mobile-friendly formatting
- Search-friendly structure

## Questions/Suggestions for Enhancement

Before I proceed with writing:

1. **Scope**: Do you want me to focus on any particular areas first (e.g., getting started vs API reference)?

2. **Examples**: Should I create examples using a specific domain (e.g., e-commerce products, user management) for consistency?

3. **Migration**: Do you want a migration guide for users coming from the current docs?

4. **Version**: Should I fix the version inconsistency to 0.2.0 or update to 0.3.0?

5. **Technical depth**: How deep should I go into Ecto query internals vs keeping it more surface-level?

The current documentation assumes too much knowledge and doesn't provide a clear learning path. My plan addresses this by creating a logical progression from "I just heard about LiveTable" to "I'm building complex, production-ready tables."

What are your thoughts on this approach? Should I proceed with this structure, or would you like me to adjust any aspects?

