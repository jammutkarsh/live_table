defmodule LiveTable.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = children(Mix.env())

    opts = [strategy: :one_for_one, name: LiveTable.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children(:test) do
    [LiveTable.Repo]
  end

  # In other environments, don't start any children
  defp children(_) do
    []
  end
end
