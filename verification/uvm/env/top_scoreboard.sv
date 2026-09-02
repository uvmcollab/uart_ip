`ifndef TOP_SCOREBOARD_SV
`define TOP_SCOREBOARD_SV

// =================== DPI FUNCTIONS ==================== //

import "DPI-C" function void debouncer_step(
  input  bit rst,
  input  bit sw,
  output bit tick_state,
  output bit level_state,
  output int unsigned cycle_counter
);

class top_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(top_scoreboard)

  `uvm_analysis_imp_decl(_observed)
  uvm_analysis_imp_observed #(debouncer_uvc_sequence_item, top_scoreboard) observed_imp_export;

  // Statistics
  int m_num_passed;
  int m_num_failed;

  // Flag indicating whether the reference model is a C++ model
  bit is_cpp_model = 0;

  // Reference model variables
  int unsigned cycle_counter = 0;
  int unsigned sync_counter = 0;
  bit sw_state = 0;
  bit level_state = 0;
  bit tick_state = 0;
  bit value_to_load;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void write_observed(debouncer_uvc_sequence_item t);
  extern function void report_phase(uvm_phase phase);

  // Reference model
  extern function debouncer_uvc_sequence_item debouncer_ref(bit rst, bit sw);
  extern function debouncer_uvc_sequence_item debouncer_cpp_ref(bit rst, bit sw);

  covergroup cg_cycle_counter;
    option.per_instance = 1;

    cp_cycle: coverpoint cycle_counter {
      bins cycle_ranges[20] = {[0:99]};
    }

    cp_level: coverpoint level_state {
      bins level_bin = {[0:1]};
    }

    cp_tick: coverpoint tick_state {
      bins tick_bin = {[0:1]};
    }

  endgroup

endclass : top_scoreboard


function top_scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
  m_num_passed = 0;
  m_num_failed = 0;
  cg_cycle_counter = new();
endfunction : new


function void top_scoreboard::build_phase(uvm_phase phase);
  observed_imp_export = new("observed_imp_export", this);
endfunction : build_phase


function void top_scoreboard::write_observed(debouncer_uvc_sequence_item t);
  debouncer_uvc_sequence_item received_trans;
  debouncer_uvc_sequence_item reference_trans;
  bit is_equal;

  // Capture transaction from monitor
  received_trans = debouncer_uvc_sequence_item::type_id::create("received_trans");
  received_trans.copy(t);

  // Select reference model
  if (is_cpp_model) begin
    reference_trans = debouncer_cpp_ref(received_trans.m_rst_i, received_trans.m_sw_i);
  end else begin
    reference_trans = debouncer_ref(received_trans.m_rst_i, received_trans.m_sw_i);
  end
  
  // Sample functional coverage
  cg_cycle_counter.sample();

  // Compare received vs reference model
  is_equal = received_trans.compare(reference_trans);

  // Statistics
  if (is_equal) begin
    m_num_passed++;
  end else begin

    // Transaction recording to for verdi Protocol Analyzer
    accept_tr(received_trans);
    void'(begin_tr(received_trans, get_full_name()));
    end_tr(received_trans);

    `uvm_info(get_type_name(), {"\nMISMATCH\n","\nRECEIVED:", received_trans.convert2string(), "\n", "\nREFMODEL:", reference_trans.convert2string(), "\n"}, UVM_MEDIUM)
    m_num_failed++;
  end
  
  // Stop condition
  if (m_num_failed >= 500) begin
    `uvm_fatal(get_name(), $sformatf("\nNumber of failures exceeded. FAILED: %4d", m_num_failed))
  end
  
endfunction : write_observed


function debouncer_uvc_sequence_item top_scoreboard::debouncer_cpp_ref(bit rst, bit sw);
  debouncer_uvc_sequence_item prediction;
  prediction = debouncer_uvc_sequence_item::type_id::create("prediction");
  debouncer_step(rst, sw, prediction.m_db_tick_o, prediction.m_db_level_o, prediction.m_cycle);
  prediction.m_rst_i = rst;
  prediction.m_sw_i = sw;

  // Save cycle counter
  cycle_counter = prediction.m_cycle;

  return prediction;
endfunction: debouncer_cpp_ref

// Spec model:
// 1. If sw remains unchanged for CounterMax cycles, counting cycles 0..CounterMax-1,
//    the value is accepted as debounced.
// 2. Outputs respond 2 cycles later.
// 3. db_tick_o pulses for one cycle only on a debounced 0->1 transition.
function debouncer_uvc_sequence_item top_scoreboard::debouncer_ref(bit rst, bit sw);
  debouncer_uvc_sequence_item prediction;

  prediction = debouncer_uvc_sequence_item::type_id::create("prediction");

  // Reset logic
  if (rst) begin
    cycle_counter = 0;
    sync_counter  = 0;

    sw_state      = 1'b0;
    level_state   = 1'b0;
    tick_state    = 1'b0;
  end else begin

    // Default value for tick
    tick_state = 1'b0;
    
    // Check debouncer condition
    if (cycle_counter == 99) begin
      if (level_state == 1'b0 && value_to_load == 1'b1) begin
        tick_state = 1'b1;
      end
      level_state = value_to_load;
    end

    // Check for changes and 2 cycle latency
    if (sw != sw_state) begin
      sync_counter = 0;
    end else begin
      if (sync_counter <= 2) begin
        sync_counter++;
      end
    end
    
    // After latency count normally
    if (sync_counter == 1) begin
      cycle_counter = 0;
      value_to_load = sw;
    end else begin
      if (cycle_counter < 99) begin
        cycle_counter++;
      end
    end

    // Update state
    sw_state = sw;
  end

  prediction.m_rst_i = rst;
  prediction.m_sw_i = sw;
  prediction.m_db_level_o = level_state;
  prediction.m_db_tick_o = tick_state;
  prediction.m_cycle = cycle_counter;
  
  return prediction;

endfunction : debouncer_ref


task top_scoreboard::run_phase(uvm_phase phase);
endtask : run_phase


function void top_scoreboard::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("\nPASSED: %5d, FAILED: %5d", m_num_passed, m_num_failed), UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("\nFinal Coverage = %3.2f", cg_cycle_counter.get_coverage()), UVM_MEDIUM)
endfunction : report_phase


`endif // TOP_SCOREBOARD_SV