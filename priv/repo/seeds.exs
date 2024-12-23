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



alias AdminTable.Repo
alias AdminTable.Catalog.{Product, Supplier, Category}

# Create Categories
categories = [
  %{name: "Electronics", description: "Cutting-edge technological devices"},
  %{name: "Clothing", description: "Fashionable apparel for all ages"},
  %{name: "Home & Kitchen", description: "Essential items for home and cooking"},
  %{name: "Books", description: "Literature and educational materials"},
  %{name: "Sporting Goods", description: "Equipment for sports and outdoor activities"},
  %{name: "Beauty & Personal Care", description: "Cosmetics and personal grooming products"},
  %{name: "Toys & Games", description: "Entertainment for children and adults"},
  %{name: "Furniture", description: "Home and office furniture"},
  %{name: "Garden & Outdoor", description: "Gardening and outdoor living products"},
  %{name: "Automotive", description: "Car parts and accessories"}
]

# Insert Categories
inserted_categories =
  Enum.map(categories, fn category_attrs ->
    changeset = Category.changeset(%Category{}, category_attrs)
    Repo.insert!(changeset)
  end)

# Create Suppliers
suppliers = [
  %{
    name: "Global Tech Distributors",
    contact_info: "sales@globaltech.com",
    address: "123 Tech Lane, Silicon Valley, CA 94000"
  },
  %{
    name: "Fashion World Wholesale",
    contact_info: "wholesale@fashionworld.com",
    address: "456 Style Street, New York, NY 10001"
  },
  %{
    name: "Kitchen Innovations Inc",
    contact_info: "orders@kitcheninnovations.com",
    address: "789 Culinary Road, Chicago, IL 60601"
  },
  %{
    name: "Book Haven Suppliers",
    contact_info: "procurement@bookhaven.com",
    address: "101 Literature Avenue, Boston, MA 02101"
  },
  %{
    name: "Sports Equipment Co",
    contact_info: "sales@sportsequipment.com",
    address: "202 Athletic Drive, Denver, CO 80201"
  },
  %{
    name: "Beauty Brands United",
    contact_info: "orders@beautybrands.com",
    address: "303 Glamour Street, Los Angeles, CA 90001"
  },
  %{
    name: "Toy Universe",
    contact_info: "wholesale@toyuniverse.com",
    address: "404 Playful Lane, Orlando, FL 32801"
  },
  %{
    name: "Furniture Masters",
    contact_info: "sales@furnituremasters.com",
    address: "505 Design Road, Dallas, TX 75201"
  },
  %{
    name: "Garden Solutions",
    contact_info: "orders@gardensolutions.com",
    address: "606 Green Way, Seattle, WA 98101"
  },
  %{
    name: "Auto Parts Direct",
    contact_info: "procurement@autopartsdirect.com",
    address: "707 Mechanic Street, Detroit, MI 48201"
  }
]

# Insert Suppliers
inserted_suppliers =
  Enum.map(suppliers, fn supplier_attrs ->
    changeset = Supplier.changeset(%Supplier{}, supplier_attrs)
    Repo.insert!(changeset)
  end)

# Function to generate random price
price_generator = fn ->
  (:rand.uniform(50000) / 100)
  |> Float.round(2)
  |> Decimal.from_float()
end

# Generate Products with random associations
products =
  Enum.flat_map(1..100, fn _index ->
    # Randomly select a category
    category = Enum.random(inserted_categories)

    # Generate 1-3 products for each iteration to ensure variety
    Enum.map(1..Enum.random(1..3), fn _ ->
      # Product name generators for each category
      product_names = %{
        "Electronics" => [
          "Smartphone",
          "Laptop",
          "Tablet",
          "Wireless Earbuds",
          "Smart Watch",
          "Bluetooth Speaker"
        ],
        "Clothing" => ["T-Shirt", "Jeans", "Hoodie", "Jacket", "Sweater", "Dress", "Shorts"],
        "Home & Kitchen" => [
          "Blender",
          "Coffee Maker",
          "Microwave",
          "Toaster",
          "Rice Cooker",
          "Kettle"
        ],
        "Books" => [
          "Sci-Fi Novel",
          "Cookbook",
          "Self-Help Book",
          "Biography",
          "Mystery Novel",
          "Children's Book"
        ],
        "Sporting Goods" => [
          "Basketball",
          "Tennis Racket",
          "Running Shoes",
          "Yoga Mat",
          "Fitness Tracker",
          "Bicycle"
        ],
        "Beauty & Personal Care" => [
          "Moisturizer",
          "Shampoo",
          "Makeup Kit",
          "Perfume",
          "Skincare Set",
          "Hair Dryer"
        ],
        "Toys & Games" => [
          "Board Game",
          "Puzzle",
          "Action Figure",
          "Remote Control Car",
          "Building Blocks",
          "Educational Toy"
        ],
        "Furniture" => [
          "Office Chair",
          "Desk Lamp",
          "Bookshelf",
          "Coffee Table",
          "Dining Chair",
          "Bedside Table"
        ],
        "Garden & Outdoor" => [
          "Plant Pot",
          "Gardening Tools",
          "Outdoor Grill",
          "Patio Furniture",
          "Bird Feeder",
          "Garden Hose"
        ],
        "Automotive" => [
          "Car Air Freshener",
          "Phone Mount",
          "Car Seat Cover",
          "Tire Pressure Gauge",
          "Jump Starter",
          "Car Vacuum"
        ]
      }

      # Generate product details
      name = Enum.random(product_names[category.name])

      product_attrs = %{
        name: "#{name} - #{:rand.uniform(100)}",
        description: "High-quality #{name} for everyday use",
        price: price_generator.(),
        stock_quantity: :rand.uniform(1000),
        category_id: category.id
      }

      # Insert product
      changeset = Product.changeset(%Product{}, product_attrs)
      product = Repo.insert!(changeset)

      # Associate with 1-3 random suppliers
      Enum.each(Enum.take_random(inserted_suppliers, :rand.uniform(3)), fn supplier ->
        # Manually insert into join table since we're using many_to_many
        Repo.insert_all("products_suppliers", [
          %{
            product_id: product.id,
            supplier_id: supplier.id,
            inserted_at: NaiveDateTime.utc_now(),
            updated_at: NaiveDateTime.utc_now()
          }
        ])
      end)

      product
    end)
  end)

# Return some statistics
IO.puts("Seeding complete!")
IO.puts("Categories created: #{length(inserted_categories)}")
IO.puts("Suppliers created: #{length(inserted_suppliers)}")
IO.puts("Total Products created: #{length(products)}")
