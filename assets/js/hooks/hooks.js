import { RangeSlider } from "./range_slider";
import { SortableColumn } from "./sortable_column";
import { Download } from "./download";

import noUiSlider from "nouislider";
import "nouislider/dist/nouislider.css";
import live_select from "live_select";

export const TableHooks = {
  RangeSlider,
  SortableColumn,
  Download,
  ...live_select,
};
