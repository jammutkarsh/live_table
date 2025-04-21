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
