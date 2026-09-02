///////////////////////////////////////////////////////////////////////////////////
// [Filename]       fpga_top.sv
// [Project]        uart_ip
// [Author]         Ciro Bermudez
// [Language]       SystemVerilog 2017 [IEEE Std. 1800-2017]
// [Created]        2024.06.22
// [Description]    Nexys A7 UART IP testing code.
// [Notes]          This code uses an oversamplig of 16.
// [Status]         Stable
// [Revisions]      -
///////////////////////////////////////////////////////////////////////////////////

module top #(
    parameter int WordLength   = 8,
    parameter int StopBitTicks = 16
) (
    input         clk_i,
    input         rst_i,
    input         sw_i,
    input  [7:0]  din_i,
    input         rx_i,
    output [7:0]  dout_o,
    output        tx_o,
    output        rx_done_tick_o,
    output        tx_done_tick_o
);

  // Signal Declaration
  wire tick;
  wire [10:0] dvsr = 11'd54;           // 115200 baudrate
  localparam fpga_freq = 100_000_000;  // 100 MHz
  localparam db_baud = 1_000;          // 10 ms debounce time

  // Instantiation
  uart_ip #(
    .WordLength  (WordLength),
    .StopBitTicks(StopBitTicks)
  ) uart_ip_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .dvsr_i(dvsr),
    .din_i(din_i),
    .rx_i(rx_i),
    .start_tx_i(tick),
    .dout_o(dout_o),
    .tx_o(tx_o),
    .rx_done_tick_o(rx_done_tick_o),
    .tx_done_tick_o(tx_done_tick_o)
  );
  
  debouncer_ip #(
    .ClkRate(fpga_freq),
    .Baud(db_baud)
  ) debouncer_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .sw_i(sw_i),
    .db_level_o(),
    .db_tick_o(tick)
  );
  
endmodule : top
