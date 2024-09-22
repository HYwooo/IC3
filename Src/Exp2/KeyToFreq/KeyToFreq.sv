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
  logic [2:0] cs_pointer;  //计数器0~7
  logic [5:0] key_state;
  logic clk_alt;
  reg state = 0;
  logic [$clog2(1000)-1:0] cnt, cycle;
  //logic clk_1kHz;


  logic [11:0] f_clk_alt;
  logic [4:0] dig[3:0];
  assign f_clk_alt = 100000 / cycle;  //100000 = 1000 * 100
  assign dig[3] = f_clk_alt / 1000;  //0
  assign dig[2] = ((f_clk_alt % 1000) / 100) | 5'b1_0000;  //加上小数点//
  assign dig[1] = (f_clk_alt % 100) / 10;
  assign dig[0] = f_clk_alt % 10;

  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
      dig_ctrl <= 'b0;
    end else begin
      case (cs_pointer)
        3'b000:  dig_ctrl <= 0;
        3'b001:  dig_ctrl <= 1;
        3'b010:  dig_ctrl <= 2;
        3'b011:  dig_ctrl <= 3;
        default: dig_ctrl <= 'b0;
      endcase
    end
  end

  //1kHz扫描片选（4位）
  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (cs_pointer == 3'b011) cs_pointer <= 0;
      else cs_pointer <= cs_pointer + 1;
    end
  end

  //频率变化
  always @(negedge rst_n or negedge key_state[0] or negedge key_state[5]) begin
    if (!rst_n) cycle <= 1000;
    else begin
      if (cycle > 50 && key_state[0] == 0) cycle <= cycle - 50;
      else if (cycle < 951 && key_state[5] == 0) cycle <= cycle + 50;
    end
  end
  //闪灯
  always @(posedge clk_alt or negedge rst_n) begin
    if (!rst_n) begin
      state <= 0;
      cnt   <= 0;
    end else begin
      if (cnt == cycle - 1) begin
        cnt   <= 0;
        state <= ~state;
      end else begin
        cnt <= cnt + 1;
      end
    end
  end
  always @(*) begin
    led[0] = state;
    led[1] = ~state;
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
      .clk(clk),
      .rst_n(rst_n),
      .cs_pointer(cs_pointer),
      .cs(cs)
  );
  LED_Decoder LED_Decoder_inst (
      .clk(clk),
      .rst_n(rst_n),
      .dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
