// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
import noUiSlider from 'nouislider';
import 'nouislider/dist/nouislider.css';
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import live_select from "live_select"

const Hooks = {
  RangeSlider: {
    mounted() {
      const container = this.el;
      const sliderTarget = container.querySelector('.slider-target');
      if (!sliderTarget) return;

      const type = container.dataset.type;
      const key = container.dataset.key !== undefined ? container.dataset.key : null;

      // Parse values based on type
      let min, max, start;
      if (type === "number") {
        min = parseFloat(container.dataset.min || "0");
        max = parseFloat(container.dataset.max || "100");
        start = container.dataset.start ? JSON.parse(container.dataset.start) : [min, max];
      } else {
        // For dates, work with timestamps
        min = new Date(container.dataset.min).getTime();
        max = new Date(container.dataset.max).getTime();
        start = container.dataset.start ?
          JSON.parse(container.dataset.start).map(d => new Date(d).getTime()) :
          [min, max];
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
          tooltips: true
        };

        // Configure based on type
        if (type === "number") {
          config.step = parseInt(container.dataset.step);
          config.pips = {
            mode: "values",
            values: [min, (min + max) / 4, (min + max) / 2, (3 * (min + max)) / 4, max],
            density: 20
          };
        } else {
          // For dates, step in days or seconds
          config.step = type === "date" ? 24 * 60 * 60 * 1000 : parseInt(container.dataset.step || "3600") * 1000;
          config.tooltips = {
            to: value => type === "date" ? formatDate(value) : formatDate(value, true),
            from: value => new Date(value).getTime()
          };
        }

        // Add CSS classes to config
        // config.cssClasses = {
        //   target: "relative h-2 rounded-full bg-gray-100 dark:bg-neutral-700",
        //   base: "w-full h-full relative z-1",
        //   origin: "absolute top-0 end-0 w-full h-full origin-[0_0] rounded-full",
        //   handle: "absolute top-1/2 end-0 w-[1.125rem] h-[1.125rem] bg-white border-4 border-blue-600 rounded-full cursor-pointer translate-x-2/4 -translate-y-2/4 dark:border-blue-500",
        //   connects: "relative z-0 w-full h-full rounded-full overflow-hidden",
        //   connect: "absolute top-0 end-0 z-1 w-full h-full bg-blue-600 origin-[0_0] dark:bg-blue-500",
        //   touchArea: "absolute -top-1 -bottom-1 -start-1 -end-1",
          // tooltip: "bg-white border border-gray-200 text-sm text-gray-800 py-1 px-2 rounded-lg mb-3 absolute bottom-full start-2/4 -translate-x-2/4 ark:bg-neutral-800 ark:border-neutral-700 ark:text-white"
        // };

        this.slider = noUiSlider.create(sliderTarget, config);

        this.slider.on('change', (values) => {
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
            [min, max] = values.map(v => parseFloat(v));
          }

          this.pushEvent("sort", {
            filters: {
              [key]: { min, max }
            }
          });
        });
      }
    },
    destroyed() {
      if (this.slider) {
        this.slider.destroy();
      }
    }
  },
  ...live_select
}
Hooks.SortableColumn = {
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

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
