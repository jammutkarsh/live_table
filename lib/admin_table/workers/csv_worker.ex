defmodule AdminTable.Workers.CsvExportWorker do
  use Oban.Worker, queue: :exports

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"headers" => headers, "query" => query}} = job) do

    case AdminTable.CsvGenerator.generate_csv(query, headers) do
      {:ok, file_path} ->
        Phoenix.PubSub.broadcast(
          AdminTable.PubSub,
          "csv_exports",
          {:csv_ready, file_path}
        )
        :ok
    end
  end
end
