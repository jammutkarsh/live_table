defmodule LiveTable.Components do
  @moduledoc false
  # Configure components in config.exs to use custom components.

  use Phoenix.Component

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="relative flex items-start">
      <div class="flex h-6 items-center">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id || @name}
          name={@name}
          value="true"
          checked={@checked}
          class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600 dark:border-gray-600 dark:bg-gray-800 dark:ring-offset-gray-900"
          {@rest}
        />
      </div>
      <div class="ml-3 text-sm leading-6">
        <label for={@id || @name} class="font-medium text-gray-900 dark:text-gray-100">
          {@label}
        </label>
        <.error :for={msg <- @errors}>{msg}</.error>
      </div>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <label :if={@label} for={@id || @name} class="block text-sm font-medium leading-6 text-gray-900 dark:text-gray-100">
        {@label}
      </label>
      <select
        id={@id || @name}
        name={@name}
        class="mt-2 block w-full rounded-md border-0 py-1.5 pl-3 pr-10 text-gray-900 ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:focus:ring-indigo-500"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <label :if={@label} for={@id || @name} class="block text-sm font-medium leading-6 text-gray-900 dark:text-gray-100">
        {@label}
      </label>
      <div class="mt-2">
        <textarea
          id={@id || @name}
          name={@name}
          class={[
            "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300",
            "placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600",
            "sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white dark:ring-gray-700",
            "dark:placeholder:text-gray-500 dark:focus:ring-indigo-500"
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div>
      <label :if={@label} for={@id || @name} class="block text-sm font-medium leading-6 text-gray-900 dark:text-gray-100">
        {@label}
      </label>
      <div class="mt-2">
        <input
          type={@type}
          name={@name}
          id={@id || @name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300",
            "placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600",
            "sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white dark:ring-gray-700",
            "dark:placeholder:text-gray-500 dark:focus:ring-indigo-500"
          ]}
          {@rest}
        />
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-2 text-sm text-red-600 dark:text-red-400">
      {render_slot(@inner_block)}
    </p>
    """
  end

  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end