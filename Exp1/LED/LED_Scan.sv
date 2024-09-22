`timescale 1ns / 1ns
module LED_Scan #(
    parameter F_CLK  = 50000000,
    parameter F_SCAN = 1000
) (
    input clk,
    input rst_n,
    output reg [7:0] cs,
    output reg [7:0] o_dig_sel
);
  logic [4:0] dig_ctrl;  //每个LED显示啥
  logic clk_div;
  logic [2:0] cs_pointer;  //计数器0~7
  always @(posedge clk_div or negedge rst_n) begin
    if (!rst_n) begin
      cs <= 8'hFF;  //全选
      dig_ctrl <= 5'h1F;  //全亮
    end else begin
      if (cs_pointer == 7) begin
        cs_pointer <= 0;
      end else begin
        cs_pointer++;
      end
      //sync one-hot chip select 
      case (cs_pointer)
        3'd0: cs <= 8'b00000001;
        3'd1: cs <= 8'b00000010;
        3'd2: cs <= 8'b00000100;
        3'd3: cs <= 8'b00001000;
        3'd4: cs <= 8'b00010000;
        3'd5: cs <= 8'b00100000;
        3'd6: cs <= 8'b01000000;
        3'd7: cs <= 8'b10000000;
        default: cs <= 8'b11111111;
      endcase
    end

  end
  
 
  Divider #(
      .DIV_NUM(F_CLK / F_SCAN),
      .DUTY(F_CLK / F_SCAN / 2)
  ) Divider_inst (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_div)
  );

  LED_Decoder LED_Decoder_inst (
      .dig_ctrl (dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
