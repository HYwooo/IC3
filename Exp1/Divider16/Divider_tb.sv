`timescale 1ns / 1ns

module Divider_tb;
  logic clk;
  logic rst_n;
  wire  clk_div;
  Divider uut (
      clk,
      rst_n,
      clk_div
  );


  initial begin
    clk   <= 0;
    rst_n <= 0;
    #10 rst_n <= 1;

    #1000 $finish;
  end
  initial forever #10 clk = ~clk;
endmodule : Divider_tb
