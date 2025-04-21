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
