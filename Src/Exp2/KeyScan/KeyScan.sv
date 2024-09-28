//KeyScan.sv
//KEY 1~4 对应 四位二进制输入(KEY1->MSB)，用于控制 7 段数码管的显示内容 
//KEY85->key[0],KEY84->key[1],KEY81->key[2],KEY80->key[3],KEY83->key[4],KEY82->key[5]
`timescale 1ns / 1ns
module KeyScan #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input clk,
    input rst_n,
    input [5:0] key,
    output logic [7:0] cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  logic [5:0] dig_ctrl_n, dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //片选指针 0~7
  logic clk_1kHz, clk_50Hz;
  assign dig_ctrl = ~dig_ctrl_n;
  //按钮 扫描片选
  always @(negedge dig_ctrl_n[5] or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (&cs_pointer) cs_pointer <= 0;  //pointer按位与 -> 全1则重置为0
      else if (!(|cs_pointer)) cs_pointer <= 3'b111;
      else cs_pointer <= cs_pointer + 1;
    end
  end
  //
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 1) begin : Gen_SimpleDebouncer
      SimpleDebouncer Debouncer_inst (
          .clk_50Hz(clk_50Hz),
          .rst_n(rst_n),
          .key(key[i]),
          .key_state(dig_ctrl_n[i])
      );
    end
  endgenerate
  //
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto50Hz (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_50Hz)
  );
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto1k (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_1kHz)
  );
  LED_CS LED_CS_inst (
      .rst_n(rst_n),
      .cs_pointer(cs_pointer),
      .cs(cs)
  );
  LED_Decoder LED_Decoder_inst (
      .rst_n(rst_n),
      .dig_ctrl(dig_ctrl[4:0]),
      .o_dig_sel(o_dig_sel)
  );
endmodule
