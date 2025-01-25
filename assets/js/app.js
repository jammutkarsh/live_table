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

let Hooks = {
  // RangeSlider: {
  //   mounted() {
  //     const container = this.el;
  //     const sliderTarget = container.querySelector('.slider-target');
  //     if (!sliderTarget) return;

  //     const min = parseFloat(container.dataset.min || "0");
  //     const max = parseFloat(container.dataset.max || "100");
  //     const start = container.dataset.start ? JSON.parse(container.dataset.start) : [min, max];
  //     const key = container.dataset.key !== undefined ? container.dataset.key : null;

  //     if (!this.slider) {
  //       this.slider = noUiSlider.create(sliderTarget,
  //         {
  //           "start": [0, 100],
  //           "range": {
  //             "min": 0,
  //             "max": 100
  //           },
  //           "connect": true,
  //           "tooltips": true,
  //           "formatter": "integer",
  //           //   "pips": "relative w-full h-10 mt-1",
  //           //   "value": "absolute top-4 -translate-x-2/4 text-sm text-gray-400",
  //           //   "marker": "absolute h-4 border-s border-gray-400"
  //           "cssClasses": {
  //             "target": "relative h-2 rounded-full bg-gray-100 ark:bg-neutral-700",
  //             "base": "w-full h-full relative z-1",
  //             "origin": "absolute top-0 end-0 w-full h-full origin-[0_0] rounded-full",
  //             "handle": "absolute top-1/2 end-0 w-[1.125rem] h-[1.125rem] bg-white border-4 border-blue-600 rounded-full cursor-pointer translate-x-2/4 -translate-y-2/4 ark:border-blue-500",
  //             "connects": "relative z-0 w-full h-full rounded-full overflow-hidden",
  //             "connect": "absolute top-0 end-0 z-1 w-full h-full bg-blue-600 origin-[0_0] ark:bg-blue-500",
  //             "touchArea": "absolute -top-1 -bottom-1 -start-1 -end-1",
  //             "tooltip": "bg-white border border-gray-200 text-sm text-gray-800 py-1 px-2 rounded-lg mb-3 absolute bottom-full start-2/4 -translate-x-2/4 ark:bg-neutral-800 ark:border-neutral-700 ark:text-white"
  //           }
  //           // }
  //           // {
  //           //   start: start,
  //           //   connect: true,
  //           //   range: {
  //           //     'min': min,
  //           //     'max': max
  //           //   }
  //         }
  //       );

  //       this.slider.on('update', (values) => {
  //         const [min, max] = values.map(v => parseFloat(v));
  //         this.pushEvent("sort", {
  //           filters: {
  //             [key]: {  // Using computed property name
  //               min: min,
  //               max: max
  //             }
  //           }
  //         });
  //       });
  //     },

  //     destroyed() {
  //       if (this.slider) {
  //         this.slider.destroy();
  //       }
  //     }
  //   }
  // };

  RangeSlider: {
    mounted() {
      const container = this.el;
      const sliderTarget = container.querySelector('.slider-target');
      if (!sliderTarget) return;

      const min = parseFloat(container.dataset.min || "0");
      const max = parseFloat(container.dataset.max || "100");
      const start = container.dataset.start ? JSON.parse(container.dataset.start) : [min, max];
      const key = container.dataset.key !== undefined ? container.dataset.key : null;

      if (!this.slider) {
        this.slider = noUiSlider.create(sliderTarget, {
          "start": start, // Use the start value from dataset or default
          "range": {
            "min": min,
            "max": max
          },
          "step": 1,
          "connect": true,
          "pips": {
            "mode": "values",
            "values": [0, 125, 250, 375, 500],
            "density": 20
          },
          "tooltips": true,
          "formatter": { type: "integer" }
          // "cssClasses": {
          //   "target": "relative h-2 rounded-full bg-gray-100 ark:bg-neutral-700",
          //   "base": "w-full h-full relative z-1",
          //   "origin": "absolute top-0 end-0 w-full h-full origin-[0_0] rounded-full",
          //   "handle": "absolute top-1/2 end-0 w-[1.125rem] h-[1.125rem] bg-white border-4 border-blue-600 rounded-full cursor-pointer translate-x-2/4 -translate-y-2/4 ark:border-blue-500",
          //   "connects": "relative z-0 w-full h-full rounded-full overflow-hidden",
          //   "connect": "absolute top-0 end-0 z-1 w-full h-full bg-blue-600 origin-[0_0] ark:bg-blue-500",
          //   "touchArea": "absolute -top-1 -bottom-1 -start-1 -end-1",
          //   "tooltip": "bg-white border border-gray-200 text-sm text-gray-800 py-1 px-2 rounded-lg mb-3 absolute bottom-full start-2/4 -translate-x-2/4 ark:bg-neutral-800 ark:border-neutral-700 ark:text-white"
          // }
        });

        this.slider.on('change', (values) => {
          console.log("Slider update", values);
          const [min, max] = values.map(v => parseFloat(v));
          this.pushEvent("sort", {
            filters: {
              [key]: {  // Using computed property name
                min: min,
                max: max
              }
            }
          });
        });
      }
    },
    destroyed() {
      console.log("RangeSlider destroyed");
      if (this.slider) {
        this.slider.destroy();
      }
    }
  },
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
