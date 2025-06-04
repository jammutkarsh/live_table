defmodule LiveTable.Repo.Migrations.CreateTestTables do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :string
      
      timestamps()
    end

    create table(:suppliers) do
      add :name, :string
      add :contact_info, :string
      add :address, :string
      
      timestamps()
    end

    create table(:products) do
      add :name, :string
      add :description, :string
      add :price, :decimal
      add :stock_quantity, :integer
      add :category_id, references(:categories, on_delete: :nothing)
      
      timestamps()
    end

    create table(:images) do
      add :url, :string
      add :product_id, references(:products, on_delete: :nothing)
      
      timestamps()
    end

    create table(:products_suppliers) do
      add :product_id, references(:products, on_delete: :delete_all)
      add :supplier_id, references(:suppliers, on_delete: :delete_all)
      
      timestamps()
    end

    create index(:products, [:category_id])
    create index(:images, [:product_id])
    create unique_index(:products_suppliers, [:product_id, :supplier_id])
  end
end