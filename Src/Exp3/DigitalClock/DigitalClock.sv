// 完成一个数字时钟的设计，数字时钟具有显示时、分、秒的功能，24 小时制式，即能
// 显示范围为 00:00:00 至 23:59:59，使用八个 8 段数码管，可用数码管的小数点位代替“:”。
// 数字时钟具有设置时间的功能。并下载该设计到 FPGA 进行实验验证。
module DigitalClock #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input clk,
    input rst_n,
    input logic [5:0] key,  //HH:MM:SS
    output logic [3:0] led,
    output logic [7:0] cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  bit [4:0] dig_ctrl = 'b0;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  bit [2:0] cs_pointer = 'b0000_0000;  //0~7
  bit [5:0] key_state;
  bit [$clog2(86400)-1:0] seconds = 0;
  bit [$clog2(60)-1:0] ss;
  bit [$clog2(60)-1:0] mm;
  bit [$clog2(24)-1:0] hh;
  bit [$clog2(99)-1:0] dignits[7:0];
  logic [7:0] o_dig_sel_wo_dot;
  assign dignits[0] = hh / 10;
  assign dignits[1] = hh % 10;
  assign dignits[2] = 0;
  assign dignits[3] = mm / 10;
  assign dignits[4] = mm % 10;
  assign dignits[5] = 0;
  assign dignits[6] = ss / 10;
  assign dignits[7] = ss % 10;

//////*************/
  bit [5:0] laststate = 'b1;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      laststate <= 'b1;
    end else begin
      if ((laststate[0] & !key_state[0]) && 1);
      if ((laststate[1] & !key_state[1]) && 1);
      if ((laststate[2] & !key_state[2]) && 1);
      if ((laststate[3] & !key_state[3]) && 1);
      if ((laststate[4] & !key_state[4]) && 1);
      if ((laststate[5] & !key_state[5]) && 1);
      laststate[0] <= key_state[0];
      laststate[5] <= key_state[5];
     
    end
  end

  //: -> .
  always @(*) begin
    if (!rst_n) begin
      dig_ctrl = 'b0;
    end else begin
      dig_ctrl = dignits[cs_pointer];
      if (cs_pointer & 'b0010_0100) o_dig_sel = 'h10;
      else o_dig_sel = o_dig_sel_wo_dot;
    end
  end

  //生成HH:MM:SS
  always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
      seconds <= 0;
    end else begin
      if (&seconds) seconds <= 0;
      else begin
        seconds <= seconds + 1;
        ss <= seconds % 60;
        mm <= (seconds / 60) % 60;
        hh <= (seconds / 3600) % 24;
      end
    end
  end

  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (&cs_pointer) cs_pointer <= 0;
      else cs_pointer <= cs_pointer + 1;
    end
  end
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto1kHz (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_1kHz)
  );
  Divider #(
      .DIV_NUM(1000),
      .DUTY(500)
  ) CLK1kHzto1Hz (
      .clk(clk_1kHz),
      .rst_n(rst_n),
      .clk_div(clk_1Hz)
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
      .o_dig_sel(o_dig_sel_wo_dot)
  );
endmodule
