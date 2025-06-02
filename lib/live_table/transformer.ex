# New module
defmodule LiveTable.Transformer do
  defstruct [:key, :options]

  def new(key, options) do
    %__MODULE__{key: key, options: options}
  end

  # This gets the full query, not dynamic conditions
  def apply(query, %__MODULE__{options: %{query_transformer: transformer}} = filter) do
    filter_data = Map.get(filter.options, :applied_data, %{})

    case transformer do
      {module, function} -> apply(module, function, [query, filter_data])
      transformer when is_function(transformer, 2) -> transformer.(query, filter_data)
      _ -> query
    end
  end
end
