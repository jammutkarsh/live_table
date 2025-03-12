defmodule LiveTable.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/gurujada/live_table"

  def project do
    [
      app: :live_table,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description:
        "A powerful LiveView component for creating dynamic, interactive tables with features like sorting, filtering, pagination, and export capabilities.",
      docs: docs()
    ]
  end

  def application do
    [
      mod: {LiveTable.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_html, "~> 4.1"},
      {:ecto, "~> 3.10"},
      {:jason, "~> 1.2"},
      {:nimble_csv, "~> 1.2"},
      {:oban, "~> 2.19"},
      {:live_select, "~> 1.0"},
      {:oban_web, "~> 2.11"},
      {:postgrex, ">= 0.0.0"},
      {:ex_doc, "~> 0.30", runtime: false},
      {:ecto_sql, "~> 3.10"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Chivukula Virinchi"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/live_table"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE priv/static/)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "readme",
      name: "LiveTable",
      source_url: @source_url,
      extras: ["README.md", "exports.md"],
      source_ref: "v#{@version}"
    ]
  end
end
