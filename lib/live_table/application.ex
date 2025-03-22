defmodule LiveTable.TestApplication do
  use Application

  def start(_type, _args) do
    children =
      if Mix.env() == :test do
        [LiveTable.Repo]
      else
        []
      end

    opts = [strategy: :one_for_one, name: LiveTable.TestSupervisor]
    Supervisor.start_link(children, opts)
  end
end
