`ifndef DEBOUNCER_UVC_DRIVER_SV
`define DEBOUNCER_UVC_DRIVER_SV

class debouncer_uvc_driver extends uvm_driver #(debouncer_uvc_sequence_item);

  `uvm_component_utils(debouncer_uvc_driver)

  virtual debouncer_uvc_if vif;
  debouncer_uvc_config     m_config;

  extern function new(string name, uvm_component parent);

  extern task run_phase(uvm_phase phase);
  extern task do_drive();

endclass : debouncer_uvc_driver


function debouncer_uvc_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


task debouncer_uvc_driver::run_phase(uvm_phase phase);
  forever begin
    seq_item_port.get_next_item(req);
    do_drive();
    seq_item_port.item_done();
  end
endtask : run_phase


task debouncer_uvc_driver::do_drive();
  // Sync with the clock
  @(vif.cb_drv);

  // Assert
  vif.cb_drv.sw_i <= 1'b1;
  repeat(req.m_cycles_asserted) @(vif.cb_drv);

  // Deassert
  vif.cb_drv.sw_i <= 1'b0;
  repeat(req.m_cycles_deasserted) @(vif.cb_drv);

  // `uvm_info(get_type_name(), m_trans.convert2string(), UVM_DEBUG)
endtask : do_drive

`endif // DEBOUNCER_UVC_DRIVER_SV