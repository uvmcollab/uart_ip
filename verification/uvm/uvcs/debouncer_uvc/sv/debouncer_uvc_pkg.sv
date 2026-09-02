`ifndef DEBOUNCER_UVC_PKG_SV
`define DEBOUNCER_UVC_PKG_SV

package debouncer_uvc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "debouncer_uvc_types.sv"
  `include "debouncer_uvc_sequence_item.sv"
  `include "debouncer_uvc_config.sv"
  `include "debouncer_uvc_sequencer.sv"
  `include "debouncer_uvc_driver.sv"
  `include "debouncer_uvc_monitor.sv"
  `include "debouncer_uvc_agent.sv"

  `include "debouncer_uvc_sequence_base.sv"

endpackage : debouncer_uvc_pkg

`endif // DEBOUNCER_UVC_PKG_SV