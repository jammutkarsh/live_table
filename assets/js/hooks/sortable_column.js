export const SortableColumn = {
  mounted() {
    this.handleClick = (event) => {
      // Only push the shift key state when the click happens
      if (event.shiftKey) {
        // Prevent the default click event from firing immediately
        event.preventDefault();

        // Push the same event as the link but with shift key info
        this.pushEvent("sort", {
          sort: this.el.getAttribute("phx-value-sort"),
          shift_key: true,
        });
      }
      // If no shift key, let the normal phx-click handle it
    };

    this.el.addEventListener("click", this.handleClick);
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleClick);
  },
};
