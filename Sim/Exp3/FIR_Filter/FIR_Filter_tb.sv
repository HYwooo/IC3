`timescale 1ns / 1ns
module FIR_Filter_tb;
  // Testbench signals
  reg sys_clk;
  reg sys_rst_n;
  reg signed [2:0] Xin;
  wire signed [6:0] Yout;

  // Instantiate the FIR_Filter module
  FIR_Filter uut (
      .sys_clk(sys_clk),
      .sys_rst_n(sys_rst_n),
      .Xin(Xin),
      .Yout(Yout)
  );

  // Clock generation
  initial begin
    sys_clk = 0;
    forever #5 sys_clk = ~sys_clk;  // 10ns period clock
  end

  // Test procedure
  initial begin
    // Initialize signals
    sys_rst_n = 0;
    Xin = 3'b000;

    // Apply reset
    #10;
    sys_rst_n = 1;

    // Apply test inputs
    #10 Xin = 3'b001;  // x[n] = 1
    #10 Xin = 3'b010;  // x[n-1] = 2
    #10 Xin = 3'b011;  // x[n-2] = 3
    #10 Xin = 3'b100;  // x[n] = 4
    #10 Xin = 3'b101;  // x[n-1] = 5
    #10 Xin = 3'b110;  // x[n-2] = 6
    #10 Xin = 3'b111;  // x[n] = 7
    #10 Xin = 3'b000;  // x[n-1] = 0

    // Finish simulation
    #50;
    $stop;
  end

  // Monitor outputs
  initial begin
    $monitor("Time: %0t | Xin: %0d | Yout: %0d", $time, Xin, Yout);
  end

endmodule
