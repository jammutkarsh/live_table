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
    css_classes: "",
    label_classes: "block text-sm font-medium leading-6 text-gray-900 dark:text-gray-100 mb-2",
    select_classes:
      "block w-full rounded-md border-0 py-1.5 pl-3 pr-10 text-gray-900 ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:focus:ring-indigo-500"
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
      <label :if={@filter.options.label} class={@filter.options.label_classes}>
        {@filter.options.label}
      </label>
      <.live_select
        field={Phoenix.Component.to_form(%{})["filters[#{@key}]"]}
        id={"#{@key}"}
        placeholder={@filter.options.placeholder || @filter.options.prompt}
        dropdown_extra_class="max-h-60 overflow-y-scroll z-50 bg-white dark:bg-gray-900 shadow-lg ring-1 ring-black ring-opacity-5 rounded-md"
        text_input_class={@filter.options.select_classes}
        text_input_selected_class="bg-gray-50 dark:bg-gray-700"
        dropdown_class="absolute mt-1 w-full rounded-md bg-white dark:bg-gray-900 shadow-lg border border-gray-200 dark:border-gray-700"
        option_class="relative px-3 py-2 hover:bg-gray-50 dark:hover:bg-gray-800 cursor-pointer transition-colors duration-150"
        selected_option_class="bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400"
        active_option_class="bg-gray-100 dark:bg-gray-800"
        mode={:tags}
        tag_class="inline-flex items-center px-2.5 py-0.5 rounded-md text-xs font-medium bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400"
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
    <div class="flex flex-col">
      <span class="text-sm font-medium text-gray-900 dark:text-gray-100">{@label}</span>
      <span class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
        ID: {@id} • {@description}
      </span>
    </div>
    """
  end

  # Custom template provided as a function
  defp render_option_template(template_fn, option) do
    template_fn.(option)
  end
end
