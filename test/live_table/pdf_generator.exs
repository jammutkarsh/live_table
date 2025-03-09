defmodule LiveTable.PdfGeneratorTest do
  use LiveTable.DataCase
  alias LiveTable.{PdfGenerator, Catalog.Product, Repo}

  setup do
    # Create test products
    {:ok, product1} =
      Repo.insert(%Product{
        name: "Test Product 1",
        description: "Description 1",
        price: Decimal.new("19.99"),
        stock_quantity: 100
      })

    {:ok, product2} =
      Repo.insert(%Product{
        name: "Test Product 2",
        description: "Description 2",
        price: Decimal.new("29.99"),
        stock_quantity: 200
      })

    on_exit(fn ->
      # Cleanup generated files
      Path.wildcard(Path.join(System.tmp_dir!(), "export-*.{tp,pdf}"))
      |> Enum.each(&File.rm/1)
    end)

    {:ok, %{product1: product1, product2: product2}}
  end

  describe "generate_pdf/2" do
    test "successfully generates PDF file with correct headers and data" do
      query =
        "from p in #{Product}, select: %{name: p.name, price: p.price, stock_quantity: p.stock_quantity}"

      header_data = [["name", "price", "stock_quantity"], ["Name", "Price", "Stock Quantity"]]

      {:ok, file_path} = PdfGenerator.generate_pdf(query, header_data)

      assert File.exists?(file_path)
      assert String.ends_with?(file_path, ".pdf")

      # Verify file size is non-zero (basic PDF validation)
      assert File.stat!(file_path).size > 0
    end

    test "handles empty result set" do
      Repo.delete_all(Product)
      query = "from p in #{Product}, select: %{name: p.name, price: p.price}"
      header_data = [["name", "price"], ["Name", "Price"]]

      {:ok, file_path} = PdfGenerator.generate_pdf(query, header_data)

      assert File.exists?(file_path)
      assert File.stat!(file_path).size > 0
    end

    test "processes data in chunks of 500" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      products =
        for i <- 1..1500 do
          %{
            name: "Product #{i}",
            description: "Description #{i}",
            price: Decimal.new("#{i}.99"),
            stock_quantity: i,
            inserted_at: now,
            updated_at: now
          }
        end

      Repo.insert_all(Product, products)

      query_string =
        "#Ecto.Query<from p in \"products\", select: %{name: p.name, price: p.price, stock: p.stock_quantity}>"

      header_data = [["name", "price", "stock"], ["Name", "Price", "Stock"]]

      chunk_spy = spawn(fn -> chunk_monitor() end)
      Process.register(chunk_spy, :chunk_monitor)

      {:ok, file_path} = PdfGenerator.generate_pdf(query_string, header_data)
      chunks = get_chunks()

      assert File.exists?(file_path)
      # 1500 records should be processed in 3 chunks
      assert length(chunks) == 4
      # But why 4 chunks?
      # Getting processed as 1500 = [500, 500, 500, 2] chunks.
      # Where are additional 2 chunks coming from?
      assert Enum.all?(chunks, fn chunk_size -> chunk_size == 500 || chunk_size == 2 end)
    end

    test "handles special characters in data" do
      {:ok, special_product} =
        Repo.insert(%Product{
          name: "Product @ with special chars",
          description: "Description with @ symbol",
          price: Decimal.new("39.99"),
          stock_quantity: 300
        })

      query =
        "from p in #{Product}, where: p.id == #{special_product.id}, select: %{name: p.name}"

      header_data = [["name"], ["Name"]]

      {:ok, file_path} = PdfGenerator.generate_pdf(query, header_data)

      assert File.exists?(file_path)
      assert File.stat!(file_path).size > 0
    end
  end

  describe "get_query/1" do
    test "successfully converts query string to Ecto query" do
      query_string = "from p in #{Product}, select: %{name: p.name, price: p.price}"
      result = PdfGenerator.get_query(query_string)

      assert %Ecto.Query{} = result
    end

    test "handles complex queries with conditions" do
      query_string = """
      from p in #{Product},
        where: p.price > 20.00,
        select: %{name: p.name, price: p.price, stock_quantity: p.stock_quantity}
      """

      result = PdfGenerator.get_query(query_string)

      assert %Ecto.Query{} = result

      data = Repo.all(result)
      assert length(data) == 1
      product = hd(data)
      assert product.name == "Test Product 2"
      assert Decimal.compare(product.price, Decimal.new("20.00")) == :gt
    end
  end

  describe "format_value/1" do
    test "formats string values correctly" do
      assert PdfGenerator.format_value("test") == "[test]"
    end

    test "escapes @ symbol in strings" do
      assert PdfGenerator.format_value("test@example.com") == "[test\\@example.com]"
    end

    test "formats non-string values" do
      assert PdfGenerator.format_value(123) == "[123]"
      assert PdfGenerator.format_value(true) == "[true]"
    end
  end

  describe "error handling" do
    test "handles invalid query string" do
      assert_raise ArgumentError, "Invalid Ecto query string", fn ->
        PdfGenerator.get_query("invalid query string")
      end
    end

    test "handles valid query string" do
      valid_query = "#Ecto.Query<from p in \"products\", select: {p.name, p.price}>"
      result = PdfGenerator.get_query(valid_query)
      assert %Ecto.Query{} = result
    end
  end

  # Helper functions for chunk monitoring
  defp chunk_monitor(chunks \\ []) do
    receive do
      {:chunk, size} ->
        chunk_monitor([size | chunks])

      {:get_chunks, pid} ->
        send(pid, {:chunks, Enum.reverse(chunks)})
    end
  end

  defp get_chunks do
    send(:chunk_monitor, {:get_chunks, self()})

    receive do
      {:chunks, chunks} -> chunks
    after
      5000 -> raise "Timeout waiting for chunks"
    end
  end
end
