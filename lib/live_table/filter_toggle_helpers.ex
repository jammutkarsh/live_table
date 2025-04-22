defmodule LiveTable.FilterToggleHelpers do
  @moduledoc """
  Provides helper functions for toggling filter visibility on mobile devices.
  """

  defmacro __using__(_opts) do
    quote do
      @doc """
      Handles the toggle_filters event to show/hide filters on mobile devices.
      This event is triggered by the "Show/Hide Filters" button in the table component.
      """
      def handle_event("toggle_filters", _params, socket) do
        # The actual toggling is handled by the FilterToggle JS hook
        # This just sends the event to the client
        {:noreply, push_event(socket, "toggle_filters", %{})}
      end
    end
  end
end
