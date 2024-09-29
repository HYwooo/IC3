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
    input i_clk,
    input i_rst_n,
    input logic [8:0] i_key,
    output logic [3:0] o_led,
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);

  bit   [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //0~7
  logic [8:0] key_state;
  bit clk_1kHz, clk_50Hz, display_state = 0;
  bit [1:0] laststate = 'b1;

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
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

  //1kHz扫描片选信号
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (display_state) begin
        if (&cs_pointer) cs_pointer <= 0;  //pointer按位与 -> 全1则重置为0
        else cs_pointer <= cs_pointer + 1;
      end else begin
        cs_pointer <= 0;
      end
    end
  end
  //
  generate
    genvar i;
    for (i = 0; i < 9; i = i + 1) begin : Gen_SimpleDebouncer
      SimpleDebouncer SimpleDebouncer_inst (
          .clk_50Hz(clk_50Hz),
          .i_rst_n(i_rst_n),
          .i_key(i_key[i]),
          .key_state(key_state[i])
      );
    end
  endgenerate
  //
  Divider #(
      .DIV_NUM(F_CLK / 50),
      .DUTY(F_CLK / 50 / 2)
  ) Clk50Mto50Hz (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_50Hz)
  );
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) Clk50Mto1k (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  );
  LED_CS LED_CS_inst (
      .i_rst_n(i_rst_n),
      .cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  LED_Decoder LED_Decoder_inst (
      .i_rst_n  (i_rst_n),
      .dig_ctrl (dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );

endmodule
