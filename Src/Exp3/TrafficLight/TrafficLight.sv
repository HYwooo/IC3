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
  bit clk_1kHz, clk_1Hz;
  bit [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  bit [2:0] cs_pointer = 'b0;  //0~7
  bit [5:0] key_state;  //消抖后按钮
  bit [$clog2(65)-1:0] cnt;
  bit [$clog2(65)-1:0] digits[4:0];

  //计时
  always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) cnt <= 0;
    else if (cnt == 'd65) cnt <= 1;
    else cnt <= cnt + 1;
  end
  //FSM
  bit [2:0] state, next_state;
  localparam RED = 3'b100, YELLOW = 3'b010, GREEN = 3'b001;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= RED;
    else state <= next_state;
  end
  //状态转移
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      next_state <= RED;
    end else begin
      case (state)
        RED: begin
          if (cnt == 25) next_state <= YELLOW;
        end
        YELLOW: begin
          if (cnt == 30) next_state <= GREEN;
          if (cnt == 65) next_state <= RED;
        end
        GREEN: begin
          if (cnt == 60) next_state <= YELLOW;
        end
        default: next_state <= RED;
      endcase
    end
  end
  //LED状态 低电平点亮
  always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) led = 4'b1111;
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
        default: led <= 4'b1111;
      endcase
  end
  //数显
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      digits[0] <= 0;
      digits[1] <= 0;
    end else begin
      case (state)
        RED: begin
          digits[0] <= (25 - cnt) / 10;
          digits[1] <= (25 - cnt) % 10;
        end
        YELLOW: begin
          if (cnt <= 30) begin
            digits[0] <= 0;
            digits[1] <= (30 - cnt) % 10;
          end else begin
            digits[0] <= 0;
            digits[1] <= (65 - cnt) % 10;
          end
        end
        GREEN: begin
          digits[0] <= (60 - cnt) / 10;
          digits[1] <= (60 - cnt) % 10;

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
      dig_ctrl  = 5'b0_1111 & digits[cs_pointer];
      //以下显示计数器的值
      digits[2] = cnt / 10;
      digits[3] = cnt % 10;
    end
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
