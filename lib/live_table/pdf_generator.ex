defmodule LiveTable.PdfGenerator do
  @moduledoc false

  # A module for generating PDF files from Ecto queries using Typst.
  # This module provides functionality to convert Ecto queries into formatted PDF files,
  # with support for custom headers and efficient streaming of large datasets. It uses
  # Typst as an intermediate format for PDF generation.

  @repo Application.compile_env(:live_table, :repo)

  # Generates a PDF file from an Ecto query with specified headers.
  def generate_pdf(query, header_data) do
    timestamp =
      DateTime.utc_now()
      |> DateTime.to_string()
      |> String.replace([" ", ":", "."], "-")
      |> String.replace(~r/[^a-zA-Z0-9\-]/, "")

    temp_path = Path.join(System.tmp_dir!(), "export-#{timestamp}.tp")
    query = get_query(query)

    case generate_typst_file(query, temp_path, header_data) do
      {:ok, path} -> compile_typst_to_pdf(path)
      error -> error
    end
  end

  defp generate_typst_file(query, path, [header_keys, header_labels]) do
    typst_template = """
    #set page(
      paper: "a4",
      margin: (x: 0.5cm, y: 0.5cm),
    )

    #set text(
      font: "Libertinus Serif",
      size: 8pt,
      weight: "regular"
    )

    #table(
      columns: (auto, ) * #{length(header_labels)},
      inset: (x: 4pt, y: 3pt),
      align: left,
      stroke: (thickness: 0.4pt, paint: rgb(80, 80, 80)),
      fill: (col, row) => {
        if row == 0 { rgb(245, 245, 245) }
        else { white }
      },

      #{generate_table_header(header_labels)},
    """

    File.write!(path, typst_template)

    case stream_data_to_file(query, path, header_keys) do
      {:ok, _} ->
        File.write!(path, "\n)", [:append])
        {:ok, path}

      error ->
        error
    end
  end

  defp generate_table_header(header_labels) do
    header_labels
    |> Enum.map(&"[*#{&1}*]")
    |> Enum.join(", ")
  end

  defp stream_data_to_file(query, path, header_keys) do
    atom_keys = Enum.map(header_keys, &String.to_atom/1)

    apply(
      @repo,
      :transaction,
      [
        fn ->
          apply(@repo, :stream, [query, [max_rows: 500]])
          |> Stream.map(fn row ->
            atom_keys
            |> Enum.map(fn key -> Map.get(row, key) |> format_value() end)
            |> Enum.join(", ")
            |> Kernel.<>(",\n")
          end)
          |> Stream.chunk_every(500)
          |> Stream.each(fn chunk ->
            if Process.whereis(:chunk_monitor) do
              send(:chunk_monitor, {:chunk, length(chunk)})
            end

            File.write!(path, Enum.join(chunk, ""), [:append])
          end)
          |> Stream.run()

          {:ok, path}
        end, [timeout: :infinity]
      ]
    )
  end

  defp compile_typst_to_pdf(tp_path) do
    pdf_path = String.replace(tp_path, ".tp", ".pdf")

    case System.cmd("typst", ["compile", tp_path, pdf_path]) do
      {_, 0} ->
        {:ok, pdf_path}

      # File.rm(tp_path)
      {error, _} ->
        {:error, "Failed to compile PDF: #{error}"}
    end
  end

  defp format_value(value) when is_binary(value) do
    value = value |> String.replace("@", "\\@")
    "[#{value}]"
  end

  defp format_value(value), do: "[#{value}]"

  def get_query(query) do
    qs =
      query
      |> String.trim_leading("#Ecto.Query<")
      |> String.trim_trailing(">")

    try do
      query =
        Code.eval_string("""
          import Ecto.Query
          #{qs}
        """)
        |> elem(0)

      case query do
        %Ecto.Query{} -> query
        _ -> raise ArgumentError, "Invalid Ecto query string"
      end
    rescue
      CompileError -> raise ArgumentError, "Invalid Ecto query string"
    end
  end
end
