`timescale 1ns / 1ns
module Divider #(
    parameter DIV_NUM = 16,
    parameter DUTY = 4
) (
    input i_clk,
    input i_rst_n,
    output logic o_clk_div
);
  logic [$clog2(DIV_NUM)-1:0] cnt;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cnt <= 'd0;
    end else begin
      if (cnt == (DIV_NUM - 1)) begin
        cnt <= 'd0;
        o_clk_div <= 1;
      end else cnt <= cnt + 1;
      if (cnt == DUTY) o_clk_div <= 0;
    end
  end


endmodule : Divider
