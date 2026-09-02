`ifndef DEBOUNCER_UVC_SEQUENCE_BASE_SV
`define DEBOUNCER_UVC_SEQUENCE_BASE_SV

class debouncer_uvc_sequence_base extends uvm_sequence #(debouncer_uvc_sequence_item);

  `uvm_object_utils(debouncer_uvc_sequence_base)
  
  rand debouncer_uvc_sequence_item m_trans;

  extern function new(string name = "");

  extern virtual task body();

endclass : debouncer_uvc_sequence_base


function debouncer_uvc_sequence_base::new(string name = "");
  super.new(name);
  m_trans = debouncer_uvc_sequence_item::type_id::create("m_trans");
endfunction : new


task debouncer_uvc_sequence_base::body();
  // Version 1: Randomize directly from sequence
  // req = debouncer_uvc_sequence_item::type_id::create("req");
  // start_item(req);
  // if ( !req.randomize() ) begin
  //   `uvm_error(get_type_name(), "Failed to randomize transaction")
  // end
  // finish_item(req);

  // Version 2: Randomize inline from virtual sequence task
  start_item(m_trans);
  finish_item(m_trans);
endtask : body

`endif // DEBOUNCER_UVC_SEQUENCE_BASE_SV