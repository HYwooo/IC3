//KeyScan.sv
//KEY 1~4 对应 四位二进制输入(KEY1->MSB)，用于控制 7 段数码管的显示内容 
//KEY85->i_key[0],KEY84->i_key[1],KEY81->i_key[2],KEY80->i_key[3],KEY83->i_key[4],KEY82->i_key[5]
`timescale 1ns / 1ns
module KeyScan #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input i_clk,
    input i_rst_n,
    input [8:0] i_key,
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  logic [5:0] dig_ctrl_n, dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //片选指针 0~7
  logic clk_1kHz, clk_50Hz;
  assign dig_ctrl = ~dig_ctrl_n;
  //按钮 扫描片选
  always @(negedge dig_ctrl_n[5] or negedge i_rst_n) begin
    if (!i_rst_n) begin
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
          .i_rst_n(i_rst_n),
          .i_key(i_key[i]),
          .key_state(dig_ctrl_n[i])
      );
    end
  endgenerate
  //
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto50Hz (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_50Hz)
  );
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto1k (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  );
  LED_CS LED_CS_inst (
      .i_rst_n(i_rst_n),
      .cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  LED_Decoder LED_Decoder_inst (
      .i_rst_n(i_rst_n),
      .dig_ctrl(dig_ctrl[4:0]),
      .o_dig_sel(o_dig_sel)
  );
endmodule
