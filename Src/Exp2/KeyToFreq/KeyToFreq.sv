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
  logic [5:0] key_state;

  bit freq_u_state, freq_d_state;  //频率增减状态
  always @(negedge key_state[0]) begin
    freq_u_state <= 1;
  end
  always @(negedge key_state[5]) begin
    freq_d_state <= 1;
  end

  logic clk_alt;
  bit   led_blink = 0;
  logic [$clog2(1000)-1:0] cnt, cycle;
  //logic clk_1kHz;


  logic [$clog2(100000)-1:0] f_clk_alt;
  logic [4:0] dignits[3:0];
  assign f_clk_alt  = 100000 / cycle;  //100000 = 1000 * 100
  assign dignits[0] = f_clk_alt / 1000;  //数字最高位在显示的左侧
  assign dignits[1] = ((f_clk_alt % 1000) / 100) | 5'b1_0000;  //加上小数点//
  assign dignits[2] = (f_clk_alt % 100) / 10;
  assign dignits[3] = f_clk_alt % 10;

  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
      dig_ctrl <= 'b0;
    end else begin
      case (cs_pointer)
        3'b000:  dig_ctrl <= dignits[0];
        3'b001:  dig_ctrl <= dignits[1];
        3'b010:  dig_ctrl <= dignits[2];
        3'b011:  dig_ctrl <= dignits[3];
        default: dig_ctrl <= 'b0;
      endcase
    end
  end

  //1kHz扫描片选（4位） 000~011
  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (cs_pointer == 3'b011) cs_pointer <= 0;
      else cs_pointer <= cs_pointer + 1;
    end
  end

  //频率变化
  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) cycle <= 1000;
    else begin
      if (freq_u_state) begin
        freq_u_state <= 0;
        if (cycle < 901) cycle <= cycle + 100;
        else if (freq_d_state) begin
          freq_d_state <= 0;
          if (cycle > 199) cycle <= cycle - 100;
        end
      end
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
