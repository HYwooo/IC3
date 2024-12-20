module DigitalClock_tb;

  // Parameters
  parameter F_CLK = 50000000;
  parameter F_CLK_SLOW = 10000000;

  // Signals
  logic i_clk;
  logic i_rst_n;
  logic [8:0] i_key;
  logic [3:0] led;
  logic [7:0] o_cs;
  logic [7:0] o_dig_sel;

  // Instantiate the DigitalClock module
  DigitalClock #(
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

  // Initial setup
  initial begin
    i_key = 6'b0;
    #200; // Wait for reset to complete

    // Test Case 1: Verify reset functionality
    assert(uut.seconds == 0) else $fatal("Reset failed: seconds != 0");
    assert(uut.ss == 0) else $fatal("Reset failed: ss != 0");
    assert(uut.mm == 0) else $fatal("Reset failed: mm != 0");
    assert(uut.hh == 0) else $fatal("Reset failed: hh != 0");

    // Test Case 2: Verify time increment functionality
    #1000000; // Wait for some time to pass
    assert(uut.seconds > 0) else $fatal("Time increment failed: seconds <= 0");

    // Test Case 3: Verify i_key press functionality
    i_key[0] = 1;
    #200 i_key[0] = 0;
    #100;
    assert(uut.key_state[0] == 1) else $fatal("Key press failed: key_state[0] != 1");

    // Test Case 4: Verify display update functionality
    #1000000; // Wait for display to update
    assert(uut.digits[0] == uut.hh / 10) else $fatal("Display update failed: digits[0] != hh / 10");
    assert(uut.digits[1] == uut.hh % 10) else $fatal("Display update failed: digits[1] != hh % 10");
    assert(uut.digits[3] == uut.mm / 10) else $fatal("Display update failed: digits[3] != mm / 10");
    assert(uut.digits[4] == uut.mm % 10) else $fatal("Display update failed: digits[4] != mm % 10");
    assert(uut.digits[6] == uut.ss / 10) else $fatal("Display update failed: digits[6] != ss / 10");
    assert(uut.digits[7] == uut.ss % 10) else $fatal("Display update failed: digits[7] != ss % 10");

    $display("All tests passed.");
    $finish;
  end

endmodule