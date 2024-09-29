`timescale 1ns / 1ns

module Divider_tb;
  logic i_clk;
  logic i_rst_n;
  wire  clk_div;
  Divider uut (
      i_clk,
      i_rst_n,
      clk_div
  );


  initial begin
    i_clk   <= 0;
    i_rst_n <= 0;
    #10 i_rst_n <= 1;

    #1000 $finish;
  end
  initial forever #10 i_clk = ~i_clk;
endmodule : Divider_tb
