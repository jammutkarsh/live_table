export const Download = {
  mounted() {
    this.handleEvent("download", ({ path }) => {
      const link = document.createElement("a");
      link.href = path;
      link.setAttribute("download", "");
      link.style.display = "none";
      document.body.appendChild(link);

      link.click();

      document.body.removeChild(link);
    });
  }
};
