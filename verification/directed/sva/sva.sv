module sva #(
    parameter int ClkFreq    = 100_000_000,
    parameter int StableTime = 10
)(
    // Interface signals
    input logic clk_i,
    input logic rst_i,
    input logic sw_i,
    input logic db_level_o,
    input logic db_tick_o,
    input logic ff1,
    input logic ff2,
    input logic ff3
);

  localparam int CounterMax = ClkFreq * StableTime / 1_000_000;

  property p1;
    @(posedge clk_i) 
    $rose(db_level_o) |-> (db_tick_o ##1 !db_tick_o);
  endproperty

  property p2;
    @(posedge clk_i) 
    ((db_level_o && $past(db_level_o)) |-> !db_tick_o);
  endproperty

  property p3;
    @(posedge clk_i) 
    $rose(ff1) |-> (##1 ff2);
    //$rose(ff1) |=> ff2;
  endproperty

  property p4;
    @(posedge clk_i) disable iff (rst_i)
    $rose(sw_i) ##0 sw_i[*CounterMax+2] |-> ##1 db_level_o;
  endproperty

  assert_p1: assert property (p1)
    else $error("[SVA ERROR] %10t: db_tick_o is was not deasserted!", $realtime);

  assert_p2: assert property (p2)
    else $error("[SVA ERROR] %10t: db_tick_o is asserted when it should not be!", $realtime);

  assert_p3: assert property (p3)
    else $error("[SVA ERROR] %10t: ff2 did not follow ff1 as expected!", $realtime);

  assert_p4: assert property (p4)
    else $error("[SVA ERROR] %10t: db_level_o did not activate as expected after sw_i was stable high!", $realtime);

  cover_p1: cover property (p1);

endmodule
