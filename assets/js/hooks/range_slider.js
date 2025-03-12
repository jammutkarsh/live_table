import noUiSlider, { cssClasses } from "nouislider";
import "nouislider/dist/nouislider.css";

export const RangeSlider = {
  mounted() {
    const container = this.el;
    const sliderTarget = container.querySelector(".slider-target");
    if (!sliderTarget) return;

    const type = container.dataset.type;
    const key =
      container.dataset.key !== undefined ? container.dataset.key : null;

    // Parse values based on type
    let min, max, start;
    if (type === "number") {
      min = parseFloat(container.dataset.min || "0");
      max = parseFloat(container.dataset.max || "100");
      start = container.dataset.start
        ? JSON.parse(container.dataset.start)
        : [min, max];
    } else {
      // For dates, work with timestamps
      min = new Date(container.dataset.min).getTime();
      max = new Date(container.dataset.max).getTime();
      start = container.dataset.start
        ? JSON.parse(container.dataset.start).map((d) => new Date(d).getTime())
        : [min, max];
    }

    const formatDate = (timestamp, isDateTime = false) => {
      const date = new Date(timestamp);
      if (isDateTime) {
        return date.toLocaleString();
      }
      return date.toLocaleDateString();
    };

    if (!this.slider) {
      const config = {
        start: start,
        range: { min, max },
        connect: true,
        tooltips: true,
      };

      // Configure based on type
      if (type === "number") {
        config.step = parseInt(container.dataset.step);
        config.pips = {
          mode: "values",
          values: [
            min,
            (min + max) / 4,
            (min + max) / 2,
            (3 * (min + max)) / 4,
            max,
          ],
          density: 20,
        };
      } else {
        // For dates, step in days or seconds
        config.step =
          type === "date"
            ? 24 * 60 * 60 * 1000
            : parseInt(container.dataset.step || "3600") * 1000;
        config.tooltips = {
          to: (value) =>
            type === "date" ? formatDate(value) : formatDate(value, true),
          from: (value) => new Date(value).getTime(),
        };
      }

      this.slider = noUiSlider.create(sliderTarget, config);

      this.slider.on("change", (values) => {
        let [min, max] = values;

        if (type !== "number") {
          // Convert to ISO strings for server
          min = new Date(parseFloat(min)).toISOString();
          max = new Date(parseFloat(max)).toISOString();

          // Remove milliseconds and adjust format for date-only
          if (type === "date") {
            min = min.split("T")[0];
            max = max.split("T")[0];
          }
        } else {
          [min, max] = values.map((v) => parseFloat(v));
        }

        this.pushEvent("sort", {
          filters: {
            [key]: { min, max },
          },
        });
      });
    }
  },

  destroyed() {
    if (this.slider) {
      this.slider.destroy();
    }
  },
};
