export const FilterToggle = {
  mounted() {
    // Get references to the elements
    this.filtersContainer = document.getElementById("filters-container");
    this.toggleText = document.getElementById("filter-toggle-text");
    
    // Set up the event handler for the toggle button event from the server
    this.handleEvent("toggle_filters", () => {
      this.toggleFilters();
    });
  },
  
  // Method to toggle the filters visibility
  toggleFilters() {
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
