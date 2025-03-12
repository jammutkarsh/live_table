import { RangeSlider } from "./range_slider";
import { SortableColumn } from "./sortable_column";
import { Download } from "./download";
import live_select from "live_select";

const TableHooks = {
  RangeSlider,
  SortableColumn,
  Download,
  ...live_select,
};

export default TableHooks;