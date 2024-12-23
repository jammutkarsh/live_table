defmodule AdminTable.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AdminTable.Timeline` context.
  """

  @doc """
  Generate a post.
  """

  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body #{System.unique_integer()}",
        likes_count: attrs[:likes_count] || 42,
        repost_count: attrs[:repost_count] || 42,
        photo_locations: attrs[:photo_locations] || ["option1", "option2"]
      })
      |> AdminTable.Timeline.create_post()

    post
  end

  def sorting_fixtures do
    [
      post_fixture(%{body: "First post", likes_count: 10, repost_count: 5}),
      post_fixture(%{body: "Second post", likes_count: 5, repost_count: 10}),
      post_fixture(%{body: "Third post", likes_count: 15, repost_count: 2})
    ]
  end
end
