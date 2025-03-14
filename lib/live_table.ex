defmodule LiveTable do
  @moduledoc """

    LiveTable is a powerful Phoenix LiveView component library that provides dynamic, interactive tables with built-in support for sorting, filtering, pagination, and data export capabilities.
    Makes use of [`Oban`](https://hex.pm/packages/oban), [`NimbleCSV`](https://hex.pm/packages/nimble_csv) and [`Typst`](https://typst.app/universe) to handle exports.

  **You can find a table with 1 Million rows [here](https://live-table.fly.dev)**

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
