defmodule AdminTable.Boolean do
  import Ecto.Query
  use Phoenix.Component

  defstruct [:field, :key, :options]

  def new(field, key, options) do
    %__MODULE__{field: field, key: key, options: options}
  end

  def apply(acc, filter) do
    Enum.reduce(filter, acc, fn
      {_, v}, nil ->
        Map.get(v, :options) |> Map.get(:condition)

      {_, v}, acc ->
        condition = Map.get(v, :options) |> Map.get(:condition)
        dynamic(^acc and ^condition)
    end)
  end
end
