///////////////////////////////////////////////////////////////////////////////////
// [Filename]       uart_tx.sv
// [Project]        uart_ip
// [Author]         Ciro Bermudez
// [Language]       SystemVerilog 2017 [IEEE Std. 1800-2017]
// [Created]        2024.06.22
// [Description]    UART IP module.
// [Notes]          This code uses an oversamplig of 16.
//                  Asynchronous active high reset signal
//                  The number of stop bits can be set to 1, 1.5, or 2.
//                  This code does not consider the parity bit.
// [Status]         Stable
// [Revisions]      -
///////////////////////////////////////////////////////////////////////////////////

module uart_ip #(
    parameter int WordLength   = 8,
    parameter int StopBitTicks = 16
) (
    input         clk_i,
    input         rst_i,
    input  [10:0] dvsr_i,
    input  [7:0]  din_i,
    input         rx_i,
    input         start_tx_i,
    output [7:0]  dout_o,
    output        tx_o,
    output        rx_done_tick_o,
    output        tx_done_tick_o
);

  wire tick;
  
  baud_gen baud_gen_inst(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .dvsr_i(dvsr_i),
    .tick_o(tick)
  );
  
  uart_rx #(
    .WordLength  (WordLength),
    .StopBitTicks(StopBitTicks)
  ) uart_rx_inst(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_i(rx_i),
    .sample_tick_i(tick),
    .rx_done_tick_o(rx_done_tick_o),
    .dout_o(dout_o)
  );

  uart_tx #(
    .WordLength  (WordLength),
    .StopBitTicks(StopBitTicks)
  ) uart_tx_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .start_tx_i(start_tx_i),
    .sample_tick_i(tick),
    .din_i(din_i),
    .tx_o(tx_o),
    .tx_done_tick_o(tx_done_tick_o)
  );

endmodule : uart_ip
