module tb;

  timeunit      1ns;
  timeprecision 1ps;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import top_test_pkg::*;

  // Clock signal
  logic clk_i = 0;
  localparam int unsigned ClkPeriod = 10_000; // 100 MHz -> 10 ns
  always #( (ClkPeriod / 2) * 1ps) clk_i = ~clk_i;

  // Reset signal
  logic rst_i = 1;
  initial begin
    repeat(5) @(posedge clk_i);
    rst_i = 0;
  end

  // Interface
  debouncer_uvc_if debouncer_uvc_vif (clk_i);
  
  assign debouncer_uvc_vif.rst_i = rst_i;

  // DUT Instantiation
  debouncer # (
    .ClkFreq(100_000_000),
    .StableTime(1)
  ) dut (
    .clk_i     (debouncer_uvc_vif.clk_i),
    .rst_i     (debouncer_uvc_vif.rst_i),
    .sw_i      (debouncer_uvc_vif.sw_i),
    .db_level_o(debouncer_uvc_vif.db_level_o),
    .db_tick_o (debouncer_uvc_vif.db_tick_o)
  );

  initial begin
    $timeformat(-12, 0, "ps", 10);
    uvm_config_db #(virtual debouncer_uvc_if)::set(null, "uvm_test_top.m_env.m_debouncer_uvc_agent", "vif", debouncer_uvc_vif);
    run_test();
  end

endmodule : tb