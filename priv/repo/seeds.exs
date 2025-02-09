# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AdminTable.Repo.insert!(%AdminTable.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AdminTable.Repo
alias AdminTable.Timeline.Post

# Create an array of posts
posts = [
  %{
    body:
      "Just finished an incredible coding marathon! 💻 Learned so much about Elixir and Phoenix today.",
    likes_count: 42,
    repost_count: 7,
    photo_locations: ["uploads/coding_setup.jpg"]
  },
  %{
    body:
      "Beautiful morning hike in the mountains. Nature never fails to amaze me! The view from the top was absolutely breathtaking. 🏔️",
    likes_count: 89,
    repost_count: 15,
    photo_locations: ["uploads/mountain_view.jpg", "uploads/hiking_trail.jpg"]
  },
  %{
    body:
      "New recipe experiment: Vegan chocolate chip cookies that actually taste amazing! Who says healthy can't be delicious? 🍪",
    likes_count: 56,
    repost_count: 12,
    photo_locations: ["uploads/vegan_cookies.jpg"]
  },
  %{
    body:
      "Excited to announce my new open-source project on GitHub! A lightweight Phoenix LiveView dashboard. 🚀",
    likes_count: 73,
    repost_count: 21,
    photo_locations: ["uploads/github_project.png"]
  },
  %{
    body:
      "Conference day! Presenting my research on functional programming paradigms. Nervous but ready! 📊",
    likes_count: 34,
    repost_count: 5,
    photo_locations: ["uploads/conference_stage.jpg"]
  },
  %{
    body: "Random thought of the day: Why do we park in driveways but drive on parkways? 🤔",
    likes_count: 67,
    repost_count: 9,
    photo_locations: []
  },
  %{
    body:
      "Weekend project: Building a custom mechanical keyboard from scratch. Soldering, programming the firmware! 🛠️",
    likes_count: 95,
    repost_count: 18,
    photo_locations: ["uploads/keyboard_build1.jpg", "uploads/keyboard_build2.jpg"]
  },
  %{
    body: "Just completed my first marathon! 4 hours and 15 minutes of pure determination. 🏃‍♀️🏅",
    likes_count: 112,
    repost_count: 24,
    photo_locations: ["uploads/marathon_finish.jpg"]
  },
  %{
    body: "Debugging be like: Is it a feature or a bug? The eternal programmer's dilemma 😅",
    likes_count: 61,
    repost_count: 8,
    photo_locations: []
  },
  %{
    body:
      "Sunset photography session. Sometimes you just need to pause and appreciate the beauty around us. 🌅",
    likes_count: 103,
    repost_count: 16,
    photo_locations: ["uploads/sunset_photo.jpg"]
  }
]

# Insert posts
Enum.each(posts, fn post ->
  %Post{}
  |> Post.changeset(post)
  |> Repo.insert!()
end)

# Print out inserted post count
IO.puts("Inserted #{Repo.aggregate(Post, :count, :id)} posts")

batch_size = 1_000
total_products = 1_000_000
max_concurrency = 8


alias AdminTable.Repo
alias AdminTable.Catalog.{Category, Product, Supplier, Image}
alias Faker

Faker.start()

# Helper functions for more meaningful data
defmodule SeedHelpers do
  def get_product_details(category_name) do
    case category_name do
      "Electronics" ->
        {Enum.random(["iPhone 14", "Samsung Galaxy S23", "MacBook Pro", "Dell XPS", "iPad Air"]),
         Enum.random(30000..150000),
         "High-quality device with premium features. Includes warranty and after-sales support."}
      "Clothing" ->
        {Enum.random(["Cotton T-Shirt", "Denim Jeans", "Formal Shirt", "Winter Jacket"]),
         Enum.random(499..3999),
         "Comfortable fit with premium fabric quality. Machine washable."}
      "Books" ->
        {Enum.random(["The Silent Patient", "Atomic Habits", "Rich Dad Poor Dad", "Think and Grow Rich"]),
         Enum.random(199..999),
         "Bestseller with excellent reader reviews. Available in paperback and hardcover."}
      "Food" ->
        {Enum.random(["Organic Honey", "Premium Coffee Beans", "Dark Chocolate", "Dried Fruits"]),
         Enum.random(99..999),
         "100% natural ingredients. No artificial preservatives."}
      _ ->
        {Enum.random(["Generic Item", "Basic Product"]),
         Enum.random(99..999),
         "Standard quality product with good value for money."}
    end
  end

  def indian_supplier_names do
    [
      "Reliance Industries",
      "Tata Enterprises",
      "Birla Corporation",
      "Mahindra Supplies",
      "Infosys Solutions",
      "Wipro Limited",
      "HCL Technologies",
      "Bajaj Electronics",
      "Godrej Industries",
      "ITC Limited",
      "Dabur India",
      "Hindustan Unilever",
      "Patanjali Ayurved",
      "Asian Paints",
      "Bharti Airtel"
    ]
  end
end

# Create categories
categories = [
  "Electronics",
  "Clothing",
  "Books",
  "Food",
  "Home & Kitchen",
  "Beauty & Personal Care",
  "Sports & Fitness",
  "Toys & Games",
  "Health & Wellness",
  "Automotive"
] |> Enum.map(fn name ->
  Category.changeset(%Category{}, %{
    name: name,
    description: "Quality #{name} from trusted brands"
  }) |> Repo.insert!()
end)

# Create suppliers with Indian names
suppliers = SeedHelpers.indian_supplier_names()
|> Enum.map(fn company_name ->
  Supplier.changeset(%Supplier{}, %{
    name: company_name,
    contact_info: "support@#{String.downcase(String.replace(company_name, " ", ""))}.in",
    address: "#{Faker.Address.street_address()}, #{Enum.random(["Mumbai", "Delhi", "Bangalore", "Chennai", "Hyderabad"])}, India"
  }) |> Repo.insert!()
end)

# Rest of your code remains same, but modify the product creation part:
1..div(total_products, batch_size)
|> Task.async_stream(
  fn batch_number ->
    Repo.transaction(fn ->
      products = Enum.map(1..batch_size, fn _ ->
        category = Enum.random(categories)
        {product_name, price_range, description} = SeedHelpers.get_product_details(category.name)
        price = Decimal.from_float((price_range / 100) |> Float.round(2))

        # Insert product
        product = Product.changeset(%Product{}, %{
          name: product_name,
          description: description,
          price: price,
          stock_quantity: :rand.uniform(1000),
          category_id: category.id
        }) |> Repo.insert!()

        # Rest of your code remains same...
        Image.changeset(%Image{}, %{
          url: "https://picsum.photos/seed/#{product.id}/400/300",
          product_id: product.id
        }) |> Repo.insert!()

        Enum.take_random(suppliers, :rand.uniform(3))
        |> Enum.each(fn supplier ->
          Repo.insert_all("products_suppliers", [%{
            product_id: product.id,
            supplier_id: supplier.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          }])
        end)

        product
      end)

      IO.puts "Completed batch #{batch_number}/#{div(total_products, batch_size)}"
      length(products)
    end, timeout: :infinity)
  end,
  max_concurrency: max_concurrency,
  timeout: :infinity
)
|> Stream.run()


IO.puts """
Seeding complete!
Categories: #{Repo.aggregate(Category, :count)}
Suppliers: #{Repo.aggregate(Supplier, :count)}
Products: #{Repo.aggregate(Product, :count)}
Images: #{Repo.aggregate(Image, :count)}
"""
