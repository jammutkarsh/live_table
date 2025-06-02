export const FilterToggle = {
  mounted() {
    // Get references to the elements
    this.filtersContainer = document.getElementById("filters-container");
    this.toggleText = document.getElementById("filter-toggle-text");
    
    // Only set up the event handler if we have the toggle button (3+ filters)
    if (this.toggleText) {
      this.handleEvent("toggle_filters", () => {
        this.toggleFilters();
      });
    }
  },
  
  // Method to toggle the filters visibility
  toggleFilters() {
    // Only proceed if we have the necessary elements
    if (!this.filtersContainer || !this.toggleText) return;
    
    // Toggle the visibility of the filters container
    const isHidden = this.filtersContainer.classList.contains("hidden");
    
    // Toggle the hidden class
    if (isHidden) {
      this.filtersContainer.classList.remove("hidden");
      this.toggleText.innerText = "Hide Filters";
    } else {
      this.filtersContainer.classList.add("hidden");
      this.toggleText.innerText = "Show Filters";
    }
  }
};
