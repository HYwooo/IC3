`timescale 1ns / 1ns

module TrafficLight_tb;
  // Parameters
  parameter F_CLK = 50000000;
  parameter F_CLK_SLOW = 10000000;//提高速度

  // Signals
  logic i_clk;
  logic i_rst_n;
  logic [8:0] i_key;
  logic [3:0] led;
  logic [7:0] o_cs;
  logic [7:0] o_dig_sel;

  // Instantiate the TrafficLight module
  TrafficLight #(
    .F_CLK(F_CLK),
    .F_CLK_SLOW(F_CLK_SLOW)
  ) uut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_key(i_key),
    .led(led),
    .o_cs(o_cs),
    .o_dig_sel(o_dig_sel)
  );

  // Clock generation
  initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk; // 50 MHz clock
  end

  // Reset generation
  initial begin
    i_rst_n = 0;
    #100 i_rst_n = 1;
  end

  // Test scenarios
  initial begin
    // Initialize inputs
    i_key = '1;

    // Wait for reset deassertion
    @(negedge i_rst_n);
    @(posedge i_rst_n);

    // Test reset behavior
    #20;
    assert(uut.state == uut.RED) else $error("Reset failed: state != RED");
    assert(led == 4'b1110) else $error("Reset failed: led != 4'b1110");

    // Test state transitions
    repeat (25) @(posedge uut.clk_1Hz); // Wait for 25 seconds
    assert(uut.state == uut.YELLOW) else $error("State transition failed: state != YELLOW");

    repeat (5) @(posedge uut.clk_1Hz); // Wait for 5 seconds
    assert(uut.state == uut.GREEN) else $error("State transition failed: state != GREEN");

    repeat (30) @(posedge uut.clk_1Hz); // Wait for 30 seconds
    assert(uut.state == uut.RED) else $error("State transition failed: state != RED");

    // Test LED outputs
    assert(led == 4'b1110) else $error("LED output failed: led != 4'b1110");

    // Test counter
    repeat (25) @(posedge uut.clk_1Hz);
    assert(uut.cnt == 25) else $error("Counter failed: cnt != 25");

    $display("All tests passed.");
    $finish;
  end
endmodule