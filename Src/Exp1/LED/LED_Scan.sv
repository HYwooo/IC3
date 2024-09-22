`timescale 1ns / 1ns
module LED_Scan #(
    parameter F_CLK  = 50000000,
    parameter F_SCAN = 1000
) (
    input clk,
    input rst_n,
    output reg [7:0] cs,  //片选信号
    output reg [7:0] o_dig_sel
);
  logic [4:0] dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic clk_1kHz;  //1kHz
  logic clk_1Hz;
  logic [2:0] cs_pointer;  //计数器0~7
  //扫描片选
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      cs <= 8'hFF;  //全选
    end else begin
      if (&cs_pointer) cs_pointer <= 0;  //pointer按位与 -> 全1则重置为0
      else cs_pointer <= cs_pointer + 1;

    end
  end
  //同步赋值
  always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
      dig_ctrl <= 5'h1_8;
    end else begin
      if (dig_ctrl == 5'b11111) begin
        dig_ctrl <= 5'b0_0000;
      end else begin
        dig_ctrl <= dig_ctrl + 1;
      end
    end
  end
  //异步片选
  always @(*) begin
    //async one-hot chip select 
    case (cs_pointer)
      3'd0: cs <= 8'b0000_0001;
      3'd1: cs <= 8'b0000_0010;
      3'd2: cs <= 8'b0000_0100;
      3'd3: cs <= 8'b0000_1000;
      3'd4: cs <= 8'b0001_0000;
      3'd5: cs <= 8'b0010_0000;
      3'd6: cs <= 8'b0100_0000;
      3'd7: cs <= 8'b1000_0000;
      default: cs <= 8'b1111_1111;
    endcase
  end
  Divider #(
      .DIV_NUM(F_CLK / F_SCAN),
      .DUTY(F_CLK / F_SCAN / 2)
  ) CLK50Mto1k (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_1kHz)
  );
  Divider #(
      .DIV_NUM(1000),
      .DUTY(500)
  ) CLK1kto1Hz (
      .clk(clk_1kHz),
      .rst_n(rst_n),
      .clk_div(clk_1Hz)
  );

  LED_Decoder LED_Decoder_inst (
      .dig_ctrl (dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
