defmodule LiveTable.FilterToggleHelpers do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def handle_event("toggle_filters", _params, socket) do
        # The actual toggling is handled by the FilterToggle JS hook
        # This just sends the event to the client
        {:noreply, push_event(socket, "toggle_filters", %{})}
      end
    end
  end
end
