`ifndef DEBOUNCER_UVC_IF_SV
`define DEBOUNCER_UVC_IF_SV

interface debouncer_uvc_if (
  input logic clk_i
);

  timeunit      1ns;
  timeprecision 1ps;

  localparam time CB_OUTPUT_SKEW = 1ns;

  import debouncer_uvc_pkg::*;

  // ================================= INPUTS ================================= //
  logic        rst_i;
  logic        sw_i;

  // ================================ OUTPUTS ================================= //
  logic        db_level_o;
  logic        db_tick_o;

  // ============================= INITIAL VALUES ============================= //

  initial begin
    // Initialize signals here
    sw_i = 0;
  end

  // ============================ CLOCKING BLOCKS ============================= //
  
  clocking cb_drv @(posedge clk_i);
    default input #1step output #CB_OUTPUT_SKEW;
    output sw_i;
  endclocking : cb_drv

  clocking cb_drv_neg @(negedge clk_i);
    default input #1step output #CB_OUTPUT_SKEW;
    output sw_i;
  endclocking : cb_drv_neg

  clocking cb_mon @(posedge clk_i);
    default input #1step output #CB_OUTPUT_SKEW;
  endclocking : cb_mon

  clocking cb_mon_neg @(negedge clk_i);
    default input #1step output #CB_OUTPUT_SKEW;
  endclocking : cb_mon_neg

endinterface : debouncer_uvc_if

`endif // DEBOUNCER_UVC_IF_SV