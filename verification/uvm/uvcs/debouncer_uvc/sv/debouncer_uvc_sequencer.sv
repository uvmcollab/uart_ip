`ifndef DEBOUNCER_UVC_SEQUENCER_SV
`define DEBOUNCER_UVC_SEQUENCER_SV

class debouncer_uvc_sequencer extends uvm_sequencer #(debouncer_uvc_sequence_item);

  `uvm_component_utils(debouncer_uvc_sequencer)

  debouncer_uvc_config m_config;

  extern function new(string name, uvm_component parent);

endclass : debouncer_uvc_sequencer


function debouncer_uvc_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

`endif // DEBOUNCER_UVC_SEQUENCER_SV