# 1 Million Rows

Demonstrating the lightning-fast performance of Phoenix LiveView, Ecto, and Elixir by handling 1 million rows of data with real-time filtering, sorting, and searching capabilities.

## Features

- ⚡ Real-time filtering across 1M+ records
- 🔍 Live search with complex conditions
- ↕️ Multi-column sorting
- 📄 Efficient pagination
- 🔄 Dynamic supplier filtering
- 💰 Price range filtering
- 🔗 Complex joins with zero performance impact

## Tech Stack

- Phoenix 1.7
- Phoenix LiveView
- Ecto with PostgreSQL
- TailwindCSS
- LiveSelect

## Getting Started

1. Clone the repository
2. Setup dependencies: `mix setup`
3. Start Phoenix server: `mix phx.server`
4. Visit [`localhost:4000`](http://localhost:4000)

## Performance

The application demonstrates optimal performance with 1 million rows by leveraging:
- Efficient SQL query building
- Smart pagination
- Indexed database columns
- LiveView's efficient DOM patching

## TODO

1. Benchmarking Dashboard
   - Add performance metrics visualization
   - Compare with traditional approaches

2. Enhanced Features
   - CSV/Excel export functionality
   - Custom filter builder
   - Infinite scroll option

3. Developer Experience
   - Add detailed API documentation
   - Create performance testing guide
   - Add load testing scripts
