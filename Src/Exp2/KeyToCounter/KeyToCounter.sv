//KeyToCounter.sv
// 设计四位的加、减 1 二进制计数器，用 FPGA 进行实验验证，并用 LED 阵列或
// 者数码管显示计数器的数值。
// a) 设计消抖电路。
// b) 一个按键是累加，按一下增加一个数。
// c) 一个按键是递减，按一下减少一个数。
module KeyToCounter #(
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

  bit   [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //0~7
  logic [5:0] key_state;
  bit clk_1kHz, display_state = 0;

  bit [1:0] laststate = 'b11;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      laststate <= 'b11;
      dig_ctrl  <= 'b0;
    end else begin
      if ((laststate[0] & !key_state[0]) && dig_ctrl < 'd15) dig_ctrl <= dig_ctrl + 5'h01;
      if ((laststate[1] & !key_state[1]) && dig_ctrl > 'd0) dig_ctrl <= dig_ctrl - 5'h01;
      laststate[0] <= key_state[0];
      laststate[1] <= key_state[1];
    end
  end
  always @(negedge key_state[5]) begin
    display_state <= ~display_state;
  end

  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (display_state == 1) begin
        if (&cs_pointer) cs_pointer <= 0;  //pointer按位与 -> 全1则重置为0
        else cs_pointer <= cs_pointer + 1;
      end else begin
        cs_pointer <= 0;
      end
    end
  end
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
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );

endmodule
