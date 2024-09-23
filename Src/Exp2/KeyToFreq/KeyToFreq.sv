`timescale 1ns / 1ns
module KeyToFreq #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input clk,
    input rst_n,
    input logic [5:0] key,
    output logic [3:0] led,
    output logic [7:0] cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  //1000Hz时钟，默认1Hz(cycle=1000)
  logic [4:0] dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //0~7
  bit [5:0] key_state;

  logic clk_alt;
  bit led_blink = 0;
  logic [$clog2(1000)-1:0] cnt, cycle;

  logic [$clog2(100000)-1:0] f_clk_alt;
  logic [4:0] dignits[7:0];
  assign f_clk_alt  = 100000 / cycle;  //100000 = 1000 * 100
  assign dignits[0] = f_clk_alt / 1000;  //数字最高位在显示的左侧
  assign dignits[1] = ((f_clk_alt % 1000) / 100) | 5'b1_0000;  //加上小数点//
  assign dignits[2] = (f_clk_alt % 100) / 10;
  assign dignits[3] = f_clk_alt % 10;
  assign dignits[4] = cycle / 1000;
  assign dignits[5] = ((cycle % 1000) / 100);
  assign dignits[6] = (cycle % 100) / 10;
  assign dignits[7] = cycle % 10;


  bit cycle_u_state, cycle_d_state;  //频率增减状态
  always @(posedge clk_alt or negedge key_state[0]) begin
    if (!key_state[0]) cycle_u_state <= 1;
    else cycle_u_state <= 0;
  end
  always @(posedge clk_alt or negedge key_state[5]) begin
    if (!key_state[5]) cycle_d_state <= 1;
    else cycle_d_state <= 0;
  end
  //组合逻辑实现
  always @(*) begin
    if (!rst_n) begin
      dig_ctrl = 'b0;
    end else begin
      dig_ctrl = dignits[cs_pointer];
    end
  end

  //1kHz扫描片选
  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (&cs_pointer) cs_pointer <= 0;
      else cs_pointer <= cs_pointer + 1;
    end
  end

  //频率变化
  always @(posedge cycle_u_state or posedge cycle_d_state or negedge rst_n) begin
    if (!rst_n) cycle <= 1000;
    else begin
      if (cycle_d_state) cycle <= (cycle - 50 >= 50) ? cycle - 50 : 50;
      else if (cycle_u_state) cycle <= (cycle + 50 <= 1000) ? cycle + 50 : 1000;

    end
  end
  //闪灯
  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
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
  end

  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50MtoAlt (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_alt)
  );
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 1) begin : Gen_ButtonDebouncer
      ButtonDebouncer ButtonDebouncer_inst (
          .clk(clk),
          .rst_n(rst_n),
          .key(key[i]),
          .key_state(key_state[i])
      );
    end
  endgenerate
  LED_CS LED_CS_inst (
      .rst_n(rst_n),
      .cs_pointer(cs_pointer),
      .cs(cs)
  );
  LED_Decoder LED_Decoder_inst (
      .rst_n(rst_n),
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
