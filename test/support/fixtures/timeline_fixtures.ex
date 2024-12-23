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
        body: "some body",
        likes_count: 42,
        photo_locations: ["option1", "option2"],
        repost_count: 42
      })
      |> AdminTable.Timeline.create_post()

    post
  end
end
