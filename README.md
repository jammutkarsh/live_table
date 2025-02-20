# 1 Million Rows

Demonstrating the lightning-fast performance of Phoenix LiveView, Ecto, and Elixir by handling 1 million rows of data with real-time filtering, sorting, and searching capabilities.
A reusable table component built in Phoenix LiveView and Ecto.
Can handle *joined fields*, *multi column sort*, *boolean*, *range*, *select* filters, all built dynamically on the fly.
Has additional support for *CSV* and *PDF* export as well. Makes use of Oban, NimbleCSV and Typst to get it done without hanging the liveview.

To demonstrate the scale and real-time feel of the entire project, I've inserted 1M rows into the database, and you can filter realtime across 1M records.

The seeds file inserts 1 million records into the database. Conventionally, such a process would be tedious and time-consuming.
But with Elixir's concurrency at our disposal, we can spawn 1000 processes, each of which inserts 1000 records, resulting in a much faster seeding.


All in all, its an excellent way to demonstrate the scalability and real-time feel of Phoenix LiveView.
Request all to try it out at the [demo site]() and raise any PRs for bugs.

## Getting Started

1. Clone the repository
2. Setup dependencies: `mix setup`
3. Start Phoenix server: `mix phx.server`
4. Visit [`localhost:4000`](http://localhost:4000)


# TODO
1. Table component view inspired from [Preline](https://preline.co).
Update classes to handle dynamic content that doesn't overflow the page.

2. Move away from LiveSelect. Develop our own select component to use. Will be made part of [Sutra UI]().

3. Use URL params to update the select component's state - to reflect what options have been chosen in the URL.

3. Upgrade the select component to have a multi-select feature. Useful when we want to filter posts of multiple selected users.

4. Upgrade the select component to dynamically use the primary key of the provided table. For now, its hardcoded as the ID, which might not always be the case.

5. Point to a function component to render view. Say posts are stored as published/not_published atom in db. Point to a function component that renders as a beautiful badge.
Should have an option to determine what to export to the CSV/PDF
