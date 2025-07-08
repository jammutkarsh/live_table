defmodule Debug do
  defmacro debug_pipeline(pipeline, debug_mode) do
    if Mix.env() == :dev do
      quote do
        case unquote(debug_mode) do
          :trace ->
            unquote(pipeline) |> dbg()

          :query ->
            unquote(pipeline) |> IO.inspect(label: "Query: ")

          :off ->
            unquote(pipeline)
        end
      end
    else
      quote do
        unquote(pipeline)
      end
    end
  end
end
