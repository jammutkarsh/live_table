# Table Configuration

LiveTable provides flexible configuration options that can be set at three different levels:
1. Default LiveTable options
2. Application-wide defaults
3. Individual table options

## Configuration Levels

### 1. LiveTable Default Options

These are the built-in defaults that come with LiveTable:

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

### 2. Application-wide Defaults

You can override LiveTable's defaults for your entire application by setting options in your `config.exs`:

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

### 3. Individual Table Options

For specific tables, you can define options by implementing the `table_options/0` function in your LiveView:

```elixir
defmodule MyAppWeb.UserLive.Index do
  use MyAppWeb, :live_view
  use LiveTable.LiveResource, schema: User, resource: "users"

  def table_options do
    %{
      pagination: %{
        enabled: true,
        sizes: [5, 10, 25]  # Custom sizes for this table only
      },
      exports: %{
        enabled: false  # Disable exports for this table
      }
    }
  end
end
```

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

## Configuration Precedence

Options are merged in the following order (later options override earlier ones):
1. LiveTable defaults
2. Application defaults (from `config.exs`)
3. Individual table options (from `table_options/0`)

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

## Best Practices

1. **Application Defaults**: Use application-wide defaults for consistent behavior across your app
2. **Table-Specific Options**: Override only the options that need to be different for specific tables
3. **Performance Considerations**: Adjust page sizes based on your data volume and performance requirements. Anything above the 50 page mark will start to see drops in performance and increase in latency.
