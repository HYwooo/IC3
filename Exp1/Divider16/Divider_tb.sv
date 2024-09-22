`timescale 1ns / 1ns

module Divider_tb;
  logic clk;
  logic rst;
  wire  clk_div;
  Divider uut (
      clk,
      rst,
      clk_div
  );

  initial forever #5 clk = ~clk;
  initial begin
    clk <= 0;
    rst <= 1;

    #10 rst <= 0;

    #1000 $finish;
  end
endmodule : Divider_tb
