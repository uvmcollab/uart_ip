`ifndef DEBOUNCER_UVC_AGENT_SV
`define DEBOUNCER_UVC_AGENT_SV

class debouncer_uvc_agent extends uvm_agent;

  `uvm_component_utils(debouncer_uvc_agent)

  uvm_analysis_port #(debouncer_uvc_sequence_item) analysis_port;

  debouncer_uvc_config    m_config;
  debouncer_uvc_sequencer m_sequencer;
  debouncer_uvc_driver    m_driver;
  debouncer_uvc_monitor   m_monitor;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : debouncer_uvc_agent


function  debouncer_uvc_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void debouncer_uvc_agent::build_phase(uvm_phase phase);
  if ( !uvm_config_db #(debouncer_uvc_config)::get(this, "", "config", m_config) ) begin
    `uvm_fatal(get_name(), "Could not retrieve debouncer_uvc_config from config db")
  end

  if (m_config.is_active == UVM_ACTIVE) begin
    m_sequencer = debouncer_uvc_sequencer::type_id::create("m_sequencer", this);
    m_driver    = debouncer_uvc_driver   ::type_id::create("m_driver",    this);
  end

  m_monitor = debouncer_uvc_monitor::type_id::create("m_monitor", this);
  analysis_port = new("analysis_port", this);
endfunction : build_phase


function void debouncer_uvc_agent::connect_phase(uvm_phase phase);
  if (m_config.vif == null) begin
    `uvm_fatal(get_name(), "debouncer_uvc virtual interface is not set!")
  end
  
  m_monitor.vif         = m_config.vif;
  m_monitor.m_config    = m_config;
  m_monitor.analysis_port.connect(this.analysis_port);
 
  if (m_config.is_active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    m_driver.vif         = m_config.vif;
    m_driver.m_config    = m_config;
    m_sequencer.m_config = m_config;
  end
endfunction : connect_phase

`endif // DEBOUNCER_UVC_AGENT_SV