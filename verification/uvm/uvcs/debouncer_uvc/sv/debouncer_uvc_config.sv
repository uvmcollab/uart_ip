`ifndef DEBOUNCER_UVC_CONFIG_SV
`define DEBOUNCER_UVC_CONFIG_SV

class debouncer_uvc_config extends uvm_object;

  `uvm_object_utils(debouncer_uvc_config)

  virtual debouncer_uvc_if vif;
  uvm_active_passive_enum  is_active = UVM_ACTIVE;

  extern function new(string name = "");

endclass : debouncer_uvc_config

function debouncer_uvc_config::new(string name = "");
  super.new(name);
endfunction : new

`endif // DEBOUNCER_UVC_CONFIG_SV