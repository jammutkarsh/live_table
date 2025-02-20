defmodule AdminTable.Workers.PdfExportWorker do
  use Oban.Worker, queue: :exports

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"header_data" => header_data, "query" => query}}) do
    case AdminTable.PdfGenerator.generate_pdf(query, header_data) do
      {:ok, file_path} ->
        Phoenix.PubSub.broadcast(
          AdminTable.PubSub,
          "exports",
          {:file_ready, file_path}
        )

        :ok
    end
  end
end
