`timescale 1ns / 1ns
module Divider #(
    parameter DIV_NUM = 16,
    parameter DUTY = 4
) (
    input clk,
    input rst_n,
    output logic clk_div
);

  logic [$clog2(DIV_NUM)-1:0] cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 'd0;
      clk_div <= 0;
    end else begin
      if (cnt == (DIV_NUM - 1)) cnt <= 'd0;
      else cnt <= cnt + 1;
      if (cnt < DUTY) clk_div <= 1;
      else if (cnt > DUTY - 1) clk_div <= 0;
    end
  end


endmodule : Divider
