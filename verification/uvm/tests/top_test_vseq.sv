`ifndef TOP_TEST_VSEQ_SV
`define TOP_TEST_VSEQ_SV

class top_test_vseq extends uvm_sequence;

  `uvm_object_utils(top_test_vseq)
  `uvm_declare_p_sequencer(top_vsqr)

  int unsigned m_cli_iter = 1000;
  int unsigned m_cli_cycles_asserted = 120;
  int unsigned m_cli_cycles_deasserted = 120;

  extern function new(string name = "");

  extern task pre_start();
  extern function string signature();
  extern task debouncer_uvc_seq(int unsigned cycles_asserted, int unsigned cycles_deasserted);
  extern task body();

endclass : top_test_vseq


function top_test_vseq::new(string name = "");
  super.new(name);
endfunction : new


task top_test_vseq::pre_start();
  // Variables
	uvm_bitstream_t config_value;

  `uvm_info(get_type_name(), $sformatf("\nCOMMAND LINE INTERFACE PASSED TO UVM"), UVM_MEDIUM)

  // Configuration for m_cli_iter from config DB, use +uvm_set_config_int=*,m_cli_iter,<value>
  if (!uvm_config_db#(uvm_bitstream_t)::get(m_sequencer, "", "m_cli_iter", config_value)) begin
    `uvm_info(get_type_name(), $sformatf("\nUsing default m_cli_iter value %0d", m_cli_iter), UVM_MEDIUM)
  end else begin
    m_cli_iter = config_value;
    `uvm_info(get_type_name(), $sformatf("\nm_cli_iter set to %0d from config DB", m_cli_iter), UVM_MEDIUM)
  end

  // Configuration for m_cli_cycles_asserted from config DB, use +uvm_set_config_int=*,m_cli_cycles_asserted,<value>
  if (!uvm_config_db#(uvm_bitstream_t)::get(m_sequencer, "", "m_cli_cycles_asserted", config_value)) begin
    `uvm_info(get_type_name(), $sformatf("\nUsing default m_cli_cycles_asserted value %0d", m_cli_cycles_asserted), UVM_MEDIUM)
  end else begin
    m_cli_cycles_asserted = config_value;
    `uvm_info(get_type_name(), $sformatf("\nm_cli_cycles_asserted set to %0d from config DB", m_cli_cycles_asserted), UVM_MEDIUM)
  end

  // Configuration for m_cli_cycles_deasserted from config DB, use +uvm_set_config_int=*,m_cli_cycles_deasserted,<value>
  if (!uvm_config_db#(uvm_bitstream_t)::get(m_sequencer, "", "m_cli_cycles_deasserted", config_value)) begin
    `uvm_info(get_type_name(), $sformatf("\nUsing default m_cli_cycles_deasserted value %0d", m_cli_cycles_deasserted), UVM_MEDIUM)
  end else begin
    m_cli_cycles_deasserted = config_value;
    `uvm_info(get_type_name(), $sformatf("\nm_cli_cycles_deasserted set to %0d from config DB", m_cli_cycles_deasserted), UVM_MEDIUM)
  end
  
endtask : pre_start


function string top_test_vseq::signature();
  string s = "";
  $sformat(s, {s, "\n"});
  $sformat(s, {s, "\n", " ##=============================================================================="});
  $sformat(s, {s, "\n", " ##===============================   SIGNATURE   ================================"});
  $sformat(s, {s, "\n", " ##=============================================================================="});
  $sformat(s, {s, "\n", " ## [Test]          top_test_vseq"});
  $sformat(s, {s, "\n", " ## [Project]       debouncer_uvc"});
  $sformat(s, {s, "\n", " ## [Author]        Ciro Bermudez"});
  $sformat(s, {s, "\n", " ## [Description]   Default test to be override by specific tests"});
  $sformat(s, {s, "\n", " ## [Status]        devel"});
  $sformat(s, {s, "\n", " ##=============================================================================="});
  $sformat(s, {s, "\n"});
  return s;
endfunction : signature


task top_test_vseq::debouncer_uvc_seq(int unsigned cycles_asserted, int unsigned cycles_deasserted);
  debouncer_uvc_sequence_base seq;
  seq = debouncer_uvc_sequence_base::type_id::create("seq");
  if (!seq.randomize() with {
    m_trans.m_cycles_asserted inside {[cycles_asserted/10 : cycles_asserted]};
    m_trans.m_cycles_deasserted inside {[cycles_deasserted/10 : cycles_deasserted]};
  }) begin
    `uvm_fatal(get_name(), "Failed to randomize sequence")
  end
  seq.start(p_sequencer.m_debouncer_sequencer);
endtask : debouncer_uvc_seq


task top_test_vseq::body();
  // Initial delay
  #(2000ns);

  // Main sequence
  repeat(m_cli_iter) begin
    debouncer_uvc_seq(m_cli_cycles_asserted, m_cli_cycles_deasserted);
  end

  // Drain time
  #(100 * 1ns);

  // Signature
  `uvm_info(get_type_name(), signature(), UVM_MEDIUM)
endtask : body

`endif // TOP_TEST_VSEQ_SV