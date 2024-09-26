`timescale 1ns / 1ns
module TrafficLight #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input clk,
    input rst_n,
    input logic [5:0] key,
    output logic [3:0] led,  //[0]red [1]yellow [2]green
    output logic [7:0] cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  logic clk_1kHz, clk_1Hz;
  bit   [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  bit   [2:0] cs_pointer = 'b0;  //0~7
  logic [5:0] key_state;  //消抖后按钮
  bit [$clog2(65)-1:0] cnt, cnt_d = 0;
  logic [$clog2(10)-1:0] digits[3:0];  //四个数码管

  //每秒跳一次cnt
  always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) cnt <= 1;
    else if (cnt == 'd65) cnt <= 1;
    else cnt <= cnt + 1;
  end

  bit [2:0] state;
  localparam RED = 3'b100, YELLOW = 3'b010, GREEN = 3'b001;
  always_comb begin
    unique case (1)
      (cnt > 0 && cnt <= 25): state = RED;
      (cnt > 25 && cnt <= 30): state = YELLOW;
      (cnt > 30 && cnt <= 60): state = GREEN;
      (cnt > 60 && cnt <= 65): state = YELLOW;
      default: state = RED;
    endcase
  end
  //LED状态 低电平点亮
  always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) led = 4'b0000;
    else
      case (state)
        RED: led <= 4'b1110;
        YELLOW: begin
          led[0] <= 1;
          led[1] <= ~led[1];
          led[2] <= 1;
          led[3] <= 1;
        end
        GREEN: led <= 4'b1011;
        default: led <= 4'b1111;  //全灭
      endcase
  end
  //数显
  always @(posedge clk_1Hz or negedge rst_n) begin

    if (!rst_n) begin
      cnt_d <= 0;
      digits[0] <= 0;
      digits[1] <= 0;
    end else begin
      //消除cnt_d 由64跳到65的状态
      //观察波形
      if (cnt < 65) cnt_d <= cnt;
      else cnt_d <= 0;
      unique case (state)
        RED: begin
          digits[0] <= (25 - cnt_d) / 10;
          digits[1] <= (25 - cnt_d) % 10;
        end
        YELLOW: begin
          if (cnt <= 30) begin
            digits[0] <= 0;
            digits[1] <= (30 - cnt_d) % 10;
          end else begin
            digits[0] <= 0;
            digits[1] <= (65 - cnt_d) % 10;
          end
        end
        GREEN: begin
          digits[0] <= (60 - cnt_d) / 10;
          digits[1] <= (60 - cnt_d) % 10;
        end
        default: begin
          digits[0] <= 0;
          digits[1] <= 0;
        end
      endcase
    end
  end
  //数显
  always @(*) begin
    if (!rst_n) begin
      dig_ctrl = 'b0;
    end else begin
      dig_ctrl = 5'b0_1111 & digits[cs_pointer];  //清除小数点
    end
    //以下显示计数器的值
    digits[2] = cnt / 10;
    digits[3] = cnt % 10;
  end
  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (cs_pointer == 'b11) cs_pointer <= 0;  //只用4个数码管
      else cs_pointer <= cs_pointer + 1;
    end
  end
  //分频产生1kHz信号
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto1k (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_1kHz)
  );
  //1kHz分频产生1Hz信号
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
      .rst_n(rst_n),
      .cs_pointer(cs_pointer),
      .cs(cs)
  );
  //LED译码器
  LED_Decoder LED_Decoder_inst (
      .rst_n(rst_n),
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
