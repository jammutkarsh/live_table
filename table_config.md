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
