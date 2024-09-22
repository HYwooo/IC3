//LEC_Scan.sv
//1kHz扫描全部8个数码管，每秒更新一次输出
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
  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
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
  //分频产生1kHz信号
  Divider #(
      .DIV_NUM(F_CLK / F_SCAN),
      .DUTY(F_CLK / F_SCAN / 2)
  ) CLK50Mto1k (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_1kHz)
  );
  //分频产生1Hz信号
  Divider #(
      .DIV_NUM(1000),
      .DUTY(500)
  ) CLK1kto1Hz (
      .clk(clk_1kHz),
      .rst_n(rst_n),
      .clk_div(clk_1Hz)
  );
  //LED片选信号
  LED_CS LED_CS_inst (
      .clk(clk),
      .rst_n(rst_n),
      .cs_pointer(cs_pointer),
      .cs(cs)
  );
  //LED译码器
  LED_Decoder LED_Decoder_inst (
      .clk(clk),
      .rst_n(rst_n),
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
