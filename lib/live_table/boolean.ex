defmodule LiveTable.Boolean do
  @moduledoc """
    A module for handling boolean (checkbox) filters in LiveTable.
    
    This module provides functionality for creating and managing boolean filters implemented
    as checkboxes in the LiveTable interface. It's designed to handle simple true/false
    filtering scenarios with customizable options and conditions.
    
    
  ## Options
  The boolean filter accepts the following options:
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
  ```
  Since the condition is a dynamic query, you can give conditions using joined fields as well.
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
  > **Note**: Remember to use aliases in the same order you defined your fields.
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
      checked={Map.has_key?(@applied_filters, @key)}
    />
    """
  end
end
