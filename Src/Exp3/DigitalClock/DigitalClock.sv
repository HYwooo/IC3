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
  bit [2:0] cs_pointer = 'b000;  //0~7
  bit [5:0] key_state;
  bit [$clog2(86400)-1:0] seconds = 0;
  bit [$clog2(60)-1:0] ss;
  bit [$clog2(60)-1:0] mm;
  bit [$clog2(24)-1:0] hh;
  blt alt = 0;
  bit [$clog2(3600)-1:0] alths;
  bit [$clog2(60)-1:0] altms;
  bit altss;
  bit [$clog2(10)-1:0] digits[7:0];
  logic [7:0] o_dig_sel_wo_dot;  //这个输出的小数点是0
  assign digits[0] = hh / 10;
  assign digits[1] = hh % 10;
  assign digits[2] = 0;
  assign digits[3] = mm / 10;
  assign digits[4] = mm % 10;
  assign digits[5] = 0;
  assign digits[6] = ss / 10;
  assign digits[7] = ss % 10;

  //////*************/没写完
  bit [5:0] laststate = '1;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      laststate <= '1;
    end else begin
      //按下
      if ((laststate[0] & !key_state[0])) begin
        alt   <= 1;
        altss <= -1;
      end
      if ((laststate[1] & !key_state[1])) begin
        alt   <= 1;
        altss <= 1;
      end
      if ((laststate[2] & !key_state[2])) begin
        alt   <= 1;
        altms <= -60;
      end
      if ((laststate[3] & !key_state[3])) begin
        alt   <= 1;
        altms <= 60;
      end
      if ((laststate[4] & !key_state[4])) begin
        alt   <= 1;
        alths <= -3600;
      end
      if ((laststate[5] & !key_state[5])) begin
        alt   <= 1;
        alths <= 3600;
      end
      //弹起
      if ((!laststate[0] & key_state[0])) begin
        alt   <= 0;
        altss <= 0;
      end
      if ((!laststate[1] & key_state[1])) begin
        alt   <= 0;
        altss <= 0;
      end
      if ((!laststate[2] & key_state[2])) begin
        alt   <= 0;
        altms <= 0;
      end
      if ((!laststate[3] & key_state[3])) begin
        alt   <= 0;
        altms <= 0;
      end
      if ((!laststate[4] & key_state[4])) begin
        alt   <= 0;
        alths <= 0;
      end
      if ((!laststate[5] & key_state[5])) begin
        alt   <= 0;
        alths <= 0;
      end
      //
      laststate[0] <= key_state[0];
      laststate[1] <= key_state[1];
      laststate[2] <= key_state[2];
      laststate[3] <= key_state[3];
      laststate[4] <= key_state[4];
      laststate[5] <= key_state[5];
      //
      ss <= seconds % 60;
      mm <= (seconds / 60) % 60;
      hh <= seconds / 3600;
    end

  end

  //: -> .
  always @(*) begin
    if (!rst_n) begin
      dig_ctrl = 'b0;
    end else begin
      dig_ctrl = digits[cs_pointer];
    end
    if (cs_pointer & 'b010 || cs_pointer & 'b101) o_dig_sel = 'h1_0;  //显示小数点
    else o_dig_sel = o_dig_sel_wo_dot;
  end

  //生成HH:MM:SS
  always @(posedge alt or posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
      seconds <= 0;
    end else begin
      if (seconds >= 86400 - 1) seconds <= 0;
      else begin
        if (alt) seconds <= seconds + alths + altms + altss;
        else seconds <= seconds + 1;
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