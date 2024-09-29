`timescale 1ns / 1ns
module KeyToFreq #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input i_clk,
    input i_rst_n,
    input logic [8:0] i_key,
    output logic [3:0] led,
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  //1000Hz时钟，默认1Hz(cycle=1000)
  bit [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  bit [2:0] cs_pointer = 'b0;  //0~7
  bit [5:0] key_state;

  bit clk_alt, clk_50Hz;
  bit led_blink = 0;
  bit unsigned [$clog2(1000)-1:0] cnt = 'b0, cycle = 'd1000;

  logic [$clog2(100000)-1:0] f_clk_alt;
  bit [4:0] digits[7:0];

  //fix:应使用bin2bcd转换数字
  assign digits[0] = f_clk_alt / 1000;  //数字最高位在显示的左侧
  assign digits[1] = ((f_clk_alt % 1000) / 100) | 5'b1_0000;  //加上小数点//
  assign digits[2] = (f_clk_alt % 100) / 10;
  assign digits[3] = f_clk_alt % 10;
  assign digits[4] = cycle / 1000;
  assign digits[5] = ((cycle % 1000) / 100);
  assign digits[6] = (cycle % 100) / 10;
  assign digits[7] = cycle % 10;



  //组合逻辑实现pointer到译码器的映射
  always @(*) begin
    if (!i_rst_n) dig_ctrl = 'b0;
    else dig_ctrl = digits[cs_pointer];
  end

  //1kHz扫描片选
  always @(posedge clk_alt or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (&cs_pointer) cs_pointer <= 0;
      else cs_pointer <= cs_pointer + 1;
    end
  end
  //频率变化
  bit [5:0] laststate = 'b1;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      laststate <= 'b11;
      cycle <= 'd1000;
    end else begin
      if ((laststate[0] & !key_state[0]) && (cycle + 'd50) <= 'd1000) cycle <= cycle + 'd50;
      if ((laststate[5] & !key_state[5]) && (cycle - 'd50) >= 'd50) cycle <= cycle - 'd50;
      laststate[0] <= key_state[0];
      laststate[5] <= key_state[5];
      f_clk_alt <= 100000 / cycle;
    end
  end
  //闪灯
  always @(posedge clk_alt or negedge i_rst_n) begin
    if (!i_rst_n) begin
      led_blink <= 0;
      cnt <= 0;
    end else begin
      if (cnt == cycle - 1) begin
        cnt <= 0;
        led_blink <= ~led_blink;
      end else begin
        cnt <= cnt + 1;
      end
    end
  end
  always @(*) begin
    led[0] = led_blink;
    led[1] = ~led_blink;
    led[2] = i_rst_n;
    led[3] = ~i_rst_n;
  end
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
  ) CLK50MtoAlt (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_alt)
  );

  generate
    genvar i;
    for (i = 0; i < 6; i = i + 1) begin : Gen_SimpleDebouncer
      SimpleDebouncer SimpleDebouncer_inst (
          .clk_50Hz(clk_50Hz),
          .i_rst_n(i_rst_n),
          .i_key(i_key[i]),
          .key_state(key_state[i])
      );
    end
  endgenerate
  LED_CS LED_CS_inst (
      .i_rst_n(i_rst_n),
      .cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  LED_Decoder LED_Decoder_inst (
      .i_rst_n(i_rst_n),
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
