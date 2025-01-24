defmodule AdminTable.Boolean do
  import Ecto.Query
  use Phoenix.Component

  defstruct [:field, :key, :options]

  def new(field, key, options) do
    %__MODULE__{field: field, key: key, options: options}
  end

  def apply(acc, %__MODULE__{options: %{condition: condition}}) do
  dynamic(^acc and ^condition)
  end

  def render(assigns) do
  ~H"""
  <AdminTableWeb.CoreComponents.input
    type="checkbox"
    name={"filters[#{@key}]"}
    label={@filter.options.label}
    checked={Map.has_key?(@filters, @key)}
  />
  """
  end
end
