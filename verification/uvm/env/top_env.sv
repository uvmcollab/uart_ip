`ifndef TOP_ENV_SV
`define TOP_ENV_SV

class top_env extends uvm_env;

  `uvm_component_utils(top_env)

  top_env_config    m_config;

  debouncer_uvc_config m_debouncer_uvc_config;
  debouncer_uvc_agent  m_debouncer_uvc_agent;

  top_scoreboard    m_scoreboard;
  top_vsqr          vsqr;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass : top_env


function top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void top_env::build_phase(uvm_phase phase);
  if (!uvm_config_db#(top_env_config)::get(this, "", "config", m_config)) begin
    `uvm_fatal(get_name(), "Could not retrieve top_env_config from config db")
  end

  // ===================== AGENT INSTANTIATION ===================== //
  m_debouncer_uvc_config = debouncer_uvc_config::type_id::create("m_debouncer_uvc_config");
  m_debouncer_uvc_config.is_active = UVM_ACTIVE;
  if (!uvm_config_db #(virtual debouncer_uvc_if)::get(this, "m_debouncer_uvc_agent", "vif", m_debouncer_uvc_config.vif)) begin
    `uvm_fatal(get_name(), "Could not retrieve debouncer_uvc_if from config db")
  end
  uvm_config_db #(debouncer_uvc_config)::set(this, "m_debouncer_uvc_agent", "config", m_debouncer_uvc_config);
  m_debouncer_uvc_agent = debouncer_uvc_agent::type_id::create("m_debouncer_uvc_agent", this);

  m_scoreboard = top_scoreboard::type_id::create("m_scoreboard",this);

  vsqr = top_vsqr::type_id::create("vsqr", this);
endfunction : build_phase


function void top_env::connect_phase(uvm_phase phase);
  vsqr.m_debouncer_sequencer = m_debouncer_uvc_agent.m_sequencer;
  m_debouncer_uvc_agent.analysis_port.connect(m_scoreboard.observed_imp_export);
endfunction : connect_phase


function void top_env::end_of_elaboration_phase(uvm_phase phase);
endfunction : end_of_elaboration_phase


function void top_env::report_phase(uvm_phase phase);
endfunction : report_phase

`endif // TOP_ENV_SV