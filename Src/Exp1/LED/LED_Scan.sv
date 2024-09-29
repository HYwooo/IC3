//LEC_Scan.sv
//1kHz扫描全部8个数码管，每秒更新一次输出
`timescale 1ns / 1ns
module LED_Scan #(
    parameter F_CLK  = 50000000,
    parameter F_SCAN = 1000
) (
    input i_clk,
    input i_rst_n,
    output reg [7:0] o_cs,  //片选信号
    output reg [7:0] o_dig_sel
);
  logic clk_1Hz, clk_1kHz;
  logic [4:0] dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //计数器0~7
  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (&cs_pointer) cs_pointer <= 0;  //pointer按位与 -> 全1则重置为0
      else cs_pointer <= cs_pointer + 1;
    end
  end
  //1Hz刷新数字 同步赋值
  always @(posedge clk_1Hz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      dig_ctrl <= 5'h1_8;
    end else begin
      if (dig_ctrl == 5'h1_F) begin
        dig_ctrl <= 5'h0_0;
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
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  );
  //1kHz分频产生1Hz信号
  Divider #(
      .DIV_NUM(1000),
      .DUTY(500)
  ) CLK1kto1Hz (
      .i_clk(clk_1kHz),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1Hz)
  );
  //LED片选信号
  LED_CS LED_CS_inst (

      .i_rst_n(i_rst_n),
      .i_cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  //LED译码器
  LED_Decoder LED_Decoder_inst (

      .i_rst_n(i_rst_n),
      .i_dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
