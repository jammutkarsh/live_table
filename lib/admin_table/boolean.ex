defmodule AdminTable.Boolean do
  import Ecto.Query
  use Phoenix.Component

  defstruct [:field, :key, :options]

  def new(field, key, options) do
    %__MODULE__{field: field, key: key, options: options}
  end

  def apply(acc, filter) do
    Enum.reduce(filter, acc, fn
      {_, %__MODULE__{options: %{condition: condition}}}, nil ->
        condition

      {_, %__MODULE__{options: %{condition: condition}}}, acc ->
        dynamic(^acc and ^condition)
    end)
  end
end
