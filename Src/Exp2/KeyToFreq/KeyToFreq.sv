`timescale 1ns / 1ns
module KeyToFreq #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input i_clk,
    input i_rst_n,
    input logic [8:0] i_key,
    output logic [3:0] o_led,
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  //1000Hz时钟，默认1Hz(cycle=1000)
  bit [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  bit [2:0] cs_pointer = 'b0;  //0~7
  bit [5:0] key_state;

  bit clk_1kHz, clk_50Hz;
  bit led_blink = 0;
  bit [11:0] cnt = 'b0, cycle = 'd1000;

  logic [$clog2(100000)-1:0] f_clk_alt;
  bit [4:0] digits[7:0];
  //bin2bcd转换数字
  logic [13:0] bin, bin2;
  logic [15:0] bcd, bcd2;
  assign bin = f_clk_alt[13:0];
  assign bin2[11:0] = cycle;
  always_comb begin
    digits[0] = {1'b0, bcd[15:12]};
    digits[1] = {1'b1, bcd[11:8]};
    digits[2] = {1'b0, bcd[7:4]};
    digits[3] = {1'b0, bcd[3:0]};
    digits[4] = {1'b0, bcd2[15:12]};
    digits[5] = {1'b0, bcd2[11:8]};
    digits[6] = {1'b0, bcd2[7:4]};
    digits[7] = {1'b0, bcd2[3:0]};
  end

  //组合逻辑实现pointer到译码器的映射
  always @(*) begin
    dig_ctrl = digits[cs_pointer];
  end

  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (&cs_pointer) cs_pointer <= 0;
    else cs_pointer <= cs_pointer + 1;
  end
  //频率变化
  bit [5:0] laststate = 'b1;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      laststate <= 'b11;
      cycle <= 'd1000;
    end else begin
      if ((laststate[0] & !key_state[0]) && cycle != 'd950) cycle <= cycle + 'd50;
      if ((laststate[5] & !key_state[5]) && cycle != 'd100) cycle <= cycle - 'd50;
      laststate[0] <= key_state[0];
      laststate[5] <= key_state[5];
      f_clk_alt <= 100000 / cycle;
    end
  end
  //闪灯
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (!i_rst_n) cnt <= 0;
    else begin
      if (cnt == cycle - 1) begin
        cnt <= 0;
        led_blink <= ~led_blink;
        o_led[0] <= ~o_led[0];
      end else cnt <= cnt + 1;
    end
  end

  bin2bcd bin2bcd_inst (
      .i_bin(bin),
      .o_bcd(bcd)
  );
  bin2bcd bin2bcd_inst2 (
      .i_bin(bin2),
      .o_bcd(bcd2)
  );
  //时钟分频到50Hz
  Divider #(
      .DIV_NUM(F_CLK / 50),
      .DUTY(F_CLK / 50 / 2)
  ) CLK50Mto50Hz (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_50Hz)
  );
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50MtoAlt (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  );

  generate
    genvar i;
    for (i = 0; i < 6; i = i + 1) begin : Gen_Debouncer
      SimpleDebouncer Debouncer_inst (
          .i_clk_50Hz(clk_50Hz),
          .i_rst_n(i_rst_n),
          .i_key(i_key[i]),
          .o_key_state(key_state[i])
      );
    end
  endgenerate
  LED_CS LED_CS_inst (
      .i_rst_n(i_rst_n),
      .i_cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  LED_Decoder LED_Decoder_inst (
      .i_rst_n(i_rst_n),
      .i_dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
