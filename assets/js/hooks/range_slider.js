import noUiSlider, { cssClasses } from "nouislider";
import "nouislider/dist/nouislider.css";

export const RangeSlider = {
  mounted() {
    const container = this.el;
    const sliderTarget = container.querySelector(".slider-target");
    if (!sliderTarget) return;

    const type = container.dataset.type;
    const key = container.dataset.key !== undefined ? container.dataset.key : null;

    // Parse values based on type
    let min, max, defaultMin, defaultMax, currentMin, currentMax;

    if (type === "number") {
      min = parseFloat(container.dataset.min);
      max = parseFloat(container.dataset.max);
      defaultMin = parseFloat(container.dataset.defaultMin);
      defaultMax = parseFloat(container.dataset.defaultMax);
      currentMin = container.dataset.currentMin ?
        parseFloat(container.dataset.currentMin) : defaultMin;
      currentMax = container.dataset.currentMax ?
        parseFloat(container.dataset.currentMax) : defaultMax;
    } else {
      // For dates and datetimes, parse without timezone
      const parseDate = (dateStr) => {
        if (!dateStr) return null;
        if (type === "datetime") {
          return new Date(dateStr.replace(/\.\d{3}Z$/, "")).getTime();
        } else {
          return new Date(dateStr.split("T")[0]).getTime();
        }
      };

      min = parseDate(container.dataset.min);
      max = parseDate(container.dataset.max);
      defaultMin = parseDate(container.dataset.defaultMin);
      defaultMax = parseDate(container.dataset.defaultMax);
      currentMin = container.dataset.currentMin ?
        parseDate(container.dataset.currentMin) : defaultMin;
      currentMax = container.dataset.currentMax ?
        parseDate(container.dataset.currentMax) : defaultMax;
    }

    const formatDate = (timestamp, isDateTime = false) => {
      const date = new Date(timestamp);
      if (isDateTime) {
        return date.toLocaleString();
      }
      return date.toLocaleDateString();
    };

    if (!this.slider) {
      // padding = JSON.parse(container.dataset.padding);
      // const finalValue = Array.isArray(padding) && padding.length === 2
      //   ? padding     // already an array of 2 numbers
      //   : [padding, padding];

      const config = {
        start: [currentMin, currentMax],
        range: { min, max },
        connect: JSON.parse(container.dataset.connect),
        tooltips: JSON.parse(container.dataset.tooltips),
        // behaviour: container.dataset.behaviour,
        // padding: finalValue,
      };

      // Configure based on type
      if (type === "number") {
        config.step = parseInt(container.dataset.step);
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

      if (container.dataset.pips === "true") {
        config.pips = {
          mode: container.dataset.pipsMode,
          values: JSON.parse(container.dataset.pipsValues), // Parse the JSON array
          density: parseInt(container.dataset.pipsDensity), // Use correct dataset name
          stepped: container.dataset.pipsStepped
        };

      }

      this.slider = noUiSlider.create(sliderTarget, config);

      this.slider.on(container.dataset.event_type, (values) => {
        let [min, max] = values;

        if (type === "number") {
          [min, max] = values.map(v => parseFloat(v));
        } else {
          if (type === "datetime") {
            min = new Date(parseFloat(min))
              .toISOString()
              .replace(/\.\d{3}Z$/, "");
            max = new Date(parseFloat(max))
              .toISOString()
              .replace(/\.\d{3}Z$/, "");
          } else if (type === "date") {
            min = new Date(parseFloat(min)).toISOString().split("T")[0];
            max = new Date(parseFloat(max)).toISOString().split("T")[0];
          }
        }

        this.pushEvent("sort", {
          filters: {
            [key]: { min, max },
          },
        });
      });
    }
  },

  updated() {
    if (this.slider) {
      const container = this.el;
      const type = container.dataset.type;
      const currentMin = container.dataset.currentMin;
      const currentMax = container.dataset.currentMax;

      // Only reset to defaults if current values are missing
      if (!currentMin || !currentMax) {
        let defaultMin, defaultMax;

        if (type === "number") {
          defaultMin = parseFloat(container.dataset.defaultMin);
          defaultMax = parseFloat(container.dataset.defaultMax);
        } else {
          defaultMin = new Date(container.dataset.defaultMin).getTime();
          defaultMax = new Date(container.dataset.defaultMax).getTime();
        }

        this.slider.set([defaultMin, defaultMax], false);
      }
    }
  },


  destroyed() {
    if (this.slider) {
      this.slider.destroy();
    }
  },
};
