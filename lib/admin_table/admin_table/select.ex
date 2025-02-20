defmodule AdminTable.Select do
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
    css_classes: "w-64 mx-4",
    label_classes: "block text-sm font-medium mb-2 ark:text-neutral-200",
    select_classes:
      "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-300 focus:ring focus:ring-primary-200 focus:ring-opacity-50"
  }

  def new(field, key, options) do
    complete_options = Map.merge(@default_options, options)
    %__MODULE__{field: field, key: key, options: complete_options}
  end

  def apply(acc, %__MODULE__{field: {table, _field}, options: %{selected: values}}) do
    dynamic([{^table, t}], ^acc and t.id in ^values)
  end

  # update to dynamically take primary key. not id.
  def apply(acc, %__MODULE__{field: _field, options: %{selected: values}}) do
    dynamic([p], ^acc and p.id in ^values)
  end

  # upgrade to use asynchronous option fetching.
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
      >
        <:option :let={option}>
          {render_option_template(@filter.options.option_template, option)}
        </:option>
      </.live_select>
    </div>
    """
  end

  def render_option_template(nil, %{label: label, value: [id, description]}) do
    assigns = %{label: label, id: id, description: description}

    ~H"""
    <span class="text-sm">{@label}</span>
    <br />
    <span class="text-xs text-gray-600">{@id} in</span>
    <span class="text-xs text-gray-600">{@description}</span>
    """
  end

  # Custom template provided as a function
  def render_option_template(template_fn, option) do
    template_fn.(option)
  end
end
