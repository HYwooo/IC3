`timescale 1ns / 1ns
module TrafficLight #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input i_clk,
    input i_rst_n,
    input logic [8:0] i_key,
    input logic [3:0] i_key_col,
    
    output logic [3:0] o_key_row,
    output logic [3:0] o_led,  //[0]red [1]yellow [2]green
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  logic clk_1kHz, clk_1Hz;
  logic [4:0] dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //0~7
  logic [$clog2(65)-1:0] cnt;
  logic [$clog2(10)-1:0] digits[1:0];  //2个数码管 其中两个是debug时显示cnt用的
  bit [3:0] led_state = '1;
  logic [1:0] state;
  localparam RED = 2'b01, YELLOW = 2'b10, GREEN = 2'b11;
  //每秒跳一次cnt
  always @(posedge clk_1Hz or negedge i_rst_n) begin
    if (!i_rst_n) cnt <= 0;
    else if (cnt == 'd60) cnt <= 1;
    else cnt <= cnt + 1;
  end
  always @(posedge clk_1Hz) begin
    if (cnt < 25) state <= RED;
    else if (cnt < 55) state <= GREEN;
    else if (cnt < 60) state <= YELLOW;
    else state <= RED;
  end
  //LED状态 低电平点亮
  always @(posedge i_clk) begin
    if (!i_rst_n) o_led <= 4'b0000;
    else
      case (state)
        RED: o_led <= 4'b1110;
        GREEN: o_led <= 4'b1011;
        YELLOW: o_led <= {2'b11,clk_1Hz,1'b1} ;
        default: o_led <= 4'b1110;
      endcase
  end
  //数显
  always_comb begin
    if (!i_rst_n) begin
      digits[0] = 0;
      digits[1] = 0;
    end else begin
      unique case (state)
        RED: begin
          digits[0] = (26 - cnt) / 10;
          digits[1] = (26 - cnt) % 10;
        end
        YELLOW: begin
          digits[0] = 0;
          digits[1] = (61 - cnt) % 10;
        end
        GREEN: begin
          digits[0] = (56 - cnt) / 10;
          digits[1] = (56 - cnt) % 10;
        end
        default: begin
          digits[0] = 0;
          digits[1] = 0;
        end
      endcase
    end
  end
  //数显
  always @(posedge clk_1Hz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      dig_ctrl <= 'b0;
    end else begin
      dig_ctrl <= digits[cs_pointer];  //清除小数点
    end
  end
  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (cs_pointer) cs_pointer <= 0;  //只用4个数码管
      else cs_pointer <= cs_pointer + 1;
    end
  end
  //分频产生1kHz信号
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
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
      .cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  //LED译码器
  LED_Decoder LED_Decoder_inst (
      .i_rst_n(i_rst_n),
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
