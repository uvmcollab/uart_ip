///////////////////////////////////////////////////////////////////////////////////
// [Filename]       uart_tx.sv
// [Project]        uart_ip
// [Author]         Ciro Bermudez
// [Language]       SystemVerilog 2017 [IEEE Std. 1800-2017]
// [Created]        2024.06.22
// [Description]    UART Transmitter Module.
// [Notes]          This code uses an oversamplig of 16.
//                  Asynchronous active high reset signal
//                  The number of stop bits can be set to 1, 1.5, or 2.
//                  This code does not consider the parity bit.
// [Status]         Stable
// [Revisions]      -
///////////////////////////////////////////////////////////////////////////////////

module uart_tx #(
    parameter int WordLength   = 8,
    parameter int StopBitTicks = 16
) (
    input  logic       clk_i,
    input  logic       rst_i,
    input  logic       start_tx_i,
    input  logic       sample_tick_i,
    input  logic [7:0] din_i,
    output logic       tx_o,
    output logic       tx_done_tick_o
);

  // FSM States
  typedef enum {
    ST_IDLE,
    ST_START,
    ST_DATA,
    ST_STOP
  } state_type_e;

  // Signal Declaration
  state_type_e state_reg, state_next;
  logic [3:0] sample_tick_counter_q, sample_tick_counter_d;
  logic [2:0] data_bit_counter_q,    data_bit_counter_d;
  logic [7:0] data_shift_buffer_q,   data_shift_buffer_d;
  logic tx_d, tx_q;

  // FSMD State and Data Registers
  always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      state_reg             <= ST_IDLE;
      sample_tick_counter_q <= 'd0;
      data_bit_counter_q    <= 'd0;
      data_shift_buffer_q   <= 'd0;
      tx_q                  <= 1'b1;
    end else begin
      state_reg             <= state_next;
      sample_tick_counter_q <= sample_tick_counter_d;
      data_bit_counter_q    <= data_bit_counter_d;
      data_shift_buffer_q   <= data_shift_buffer_d;
      tx_q                  <= tx_d;
    end
  end

  // FSMD Next-State Logic
  always_comb begin
    state_next            = state_reg;
    tx_done_tick_o        = 1'b0;
    sample_tick_counter_d = sample_tick_counter_q;
    data_bit_counter_d    = data_bit_counter_q;
    data_shift_buffer_d   = data_shift_buffer_q;
    tx_d                  = tx_q;
    case (state_reg)
      ST_IDLE: begin
        tx_d = 1'b1;
        if (start_tx_i) begin
          state_next            = ST_START;
          sample_tick_counter_d = 'd0;
          data_shift_buffer_d   = din_i;
        end
      end
      ST_START: begin
        tx_d = 1'b0;
        if (sample_tick_i) begin
          if (sample_tick_counter_q == 'd15) begin
            state_next            = ST_DATA;
            sample_tick_counter_d = 'd0;
            data_bit_counter_d    = 'd0;
          end else begin
            sample_tick_counter_d = sample_tick_counter_q + 'd1;
          end
        end
      end
      ST_DATA: begin
        tx_d = data_shift_buffer_q[0];
        if (sample_tick_i) begin
          if (sample_tick_counter_q == 'd15) begin
            sample_tick_counter_d = 'd0;
            data_shift_buffer_d   = data_shift_buffer_q >> 1;
            if (data_bit_counter_q == (WordLength - 1)) begin
              state_next = ST_STOP;
            end else begin
              data_bit_counter_d = data_bit_counter_q + 'd1;
            end
          end else begin
            sample_tick_counter_d = sample_tick_counter_q + 'd1;
          end
        end
      end
      ST_STOP: begin
        tx_d = 1'b1;
        if (sample_tick_i) begin
          if (sample_tick_counter_q == (StopBitTicks - 1)) begin
            state_next     = ST_IDLE;
            tx_done_tick_o = 1'b1;
          end else begin
            sample_tick_counter_d = sample_tick_counter_q + 'd1;
          end
        end
      end
    endcase
  end

  // Output
  assign tx_o = tx_q;

endmodule : uart_tx
