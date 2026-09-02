`ifndef DEBOUNCER_UVC_SEQUENCE_ITEM_SV
`define DEBOUNCER_UVC_SEQUENCE_ITEM_SV

class debouncer_uvc_sequence_item extends uvm_sequence_item;

  `uvm_object_utils(debouncer_uvc_sequence_item)

  // Transaction variables
  rand int unsigned    m_cycles_asserted;
  rand int unsigned    m_cycles_deasserted;
  
  // Monitoring values
  bit                  m_rst_i;
  bit                  m_sw_i;
  bit                  m_db_level_o;
  bit                  m_db_tick_o;
  realtime             m_sample_time;
  int unsigned         m_cycle;

  extern function new(string name = "");

  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function string convert2string();

endclass : debouncer_uvc_sequence_item


function debouncer_uvc_sequence_item::new(string name = "");
  super.new(name);
endfunction : new


function void debouncer_uvc_sequence_item::do_copy(uvm_object rhs);
  debouncer_uvc_sequence_item rhs_;
  if (!$cast(rhs_, rhs)) `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  m_rst_i       = rhs_.m_rst_i;
  m_sw_i        = rhs_.m_sw_i;
  m_db_level_o  = rhs_.m_db_level_o;
  m_db_tick_o   = rhs_.m_db_tick_o;
  m_sample_time = rhs_.m_sample_time;
  m_cycle       = rhs_.m_cycle;
endfunction : do_copy


function bit debouncer_uvc_sequence_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  debouncer_uvc_sequence_item rhs_;
  if (!$cast(rhs_, rhs)) `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  // result &= (m_rst_i       == rhs_.m_rst_i);
  // result &= (m_sw_i        == rhs_.m_sw_i);
  // result &= (m_sample_time == rhs_.m_sample_time);
  // result &= (m_cycle       == rhs_.m_cycle);

  // Just compare outputs
  result &= (m_db_level_o  == rhs_.m_db_level_o);
  result &= (m_db_tick_o   == rhs_.m_db_tick_o);
  return result;
endfunction : do_compare


function void debouncer_uvc_sequence_item::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0) `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else printer.m_string = convert2string();
endfunction : do_print


function void debouncer_uvc_sequence_item::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Random values
  `uvm_record_field("m_cycles_asserted", m_cycles_asserted)
  `uvm_record_field("m_cycles_deasserted", m_cycles_deasserted)

  // Monitor 
  `uvm_record_field("m_rst_i", m_rst_i)
  `uvm_record_field("m_sw_i", m_sw_i)
  `uvm_record_field("m_db_level_o", m_db_level_o)
  `uvm_record_field("m_db_tick_o", m_db_tick_o)
  `uvm_record_field("m_sample_time", m_sample_time)
  `uvm_record_field("m_cycle", m_cycle)
endfunction : do_record


function string debouncer_uvc_sequence_item::convert2string();
  string s;
  s = super.convert2string();
  $sformat(s, {s, "\n", "m_rst_i = %d"}, m_rst_i);
  $sformat(s, {s, "\n", "m_sw_i = %d"}, m_sw_i);
  $sformat(s, {s, "\n", "m_db_level_o = %d"}, m_db_level_o);
  $sformat(s, {s, "\n", "m_db_tick_o = %d"}, m_db_tick_o);
  $sformat(s, {s, "\n", "m_sample_time = %10t"}, m_sample_time);
  $sformat(s, {s, "\n", "m_cycle = %4d"}, m_cycle);
  return s;
endfunction : convert2string

`endif // DEBOUNCER_UVC_SEQUENCE_ITEM_SV