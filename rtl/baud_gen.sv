///////////////////////////////////////////////////////////////////////////////////
// [Filename]       baud_gen.sv
// [Project]        uart_ip
// [Author]         Ciro Bermudez
// [Language]       SystemVerilog 2017 [IEEE Std. 1800-2017]
// [Created]        2024.06.22
// [Description]    Module for generating baud rate for UART communication.
//                  Asynchronous active high reset signal
//                  Equation:
//                            dvsr_i = f_fpga/(baud_rate*16)
// [Notes]          This module supports configurable baud rates, see C++ code.
// [Status]         Stable
///////////////////////////////////////////////////////////////////////////////////

module baud_gen (
    input         clk_i,
    input         rst_i,
    input  [10:0] dvsr_i,
    output        tick_o
);

  // Signal Declaration
  logic [10:0] counter_d, counter_q;
  logic counter_done;

  // Register
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      counter_q <= 'd0;
    end else begin
      counter_q <= counter_d;
    end
  end

  // Next-State Logic
  assign counter_done = (counter_q == dvsr_i - 'd1) ? 1'b1 : 1'b0;
  assign counter_d = (counter_done) ? 'd0 : counter_q + 'd1;

  // Output 
  assign tick_o = counter_done;

endmodule : baud_gen
