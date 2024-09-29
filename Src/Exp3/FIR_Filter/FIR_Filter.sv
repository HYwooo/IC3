module FIR_Filter #(
    parameter F_CLK = 50000000,
    parameter F_CLK_SLOW = 1000
) (
    input i_clk,  // 系统时钟
    input i_rst_n,  // 复位键，低电平有效
    input logic [8:0] i_key,

    output logic [3:0] o_led,  //[0]red [1]yellow [2]green
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);
  logic clk_1kHz, clk_50Hz;
  logic [2:0] Xin;  // 滤波器的输入数据，输入速率
  logic [11:0] Yout;  // 滤波器的输出数据

  logic [4:0] dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //0~7
  logic [$clog2(10)-1:0] digits[7:0];  //2个数码管 其中两个是debug时显示cnt用的
  logic [8:0] key_state;

  assign Xin[2] = ~key_state[5];
  assign Xin[1] = ~key_state[4];
  assign Xin[0] = ~key_state[3];
  //1kHz扫描片选
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cs_pointer <= 0;
    end else begin
      if (cs_pointer) cs_pointer <= 0;  //只用4个数码管
      else cs_pointer <= cs_pointer + 1;
    end
  end
  //组合逻辑实现pointer到译码器的映射
  always @(*) begin
    if (!i_rst_n) dig_ctrl = 'b0;
    else dig_ctrl = digits[cs_pointer];
  end
  assign digits[1] = (Yout / 10) % 10;
  assign digits[0] = (Yout / 100) | 12'b0000_0001_0000;
  generate
    genvar i;
    for (i = 0; i < 9; i = i + 1) begin : Gen_Debouncer
      ButtonDebouncer ButtonDebouncer_inst (
          .i_clk(clk),
          .i_rst_n(i_rst_n),
          .i_key(i_key[i]),
          .o_key_state(key_state[i])
      );
    end
  endgenerate
  FIR_Filter_Core FIR_Filter_Core_inst (
      .i_clk(~key_state[0]),
      .i_rst_n(i_rst_n),
      .Xin(Xin),
      .Yout(Yout)
  );
  //分频产生50Hz信号
  Divider #(
      .DIV_NUM(F_CLK / 50),
      .DUTY(F_CLK / 50 / 2)
  ) Clk50Mto50Hz (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_50Hz)
  );
  //分频产生1kHz信号
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto1k (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  );
  //LED片选信号
  LED_CS LED_CS_inst (
      .i_rst_n(i_rst_n),
      .i_cs_pointer(cs_pointer),
      .o_cs(o_cs)
  );
  //LED译码器
  LED_Decoder LED_Decoder_inst (
      .i_rst_n(i_rst_n),
      .i_dig_ctrl(dig_ctrl),
      .o_dig_sel(o_dig_sel)
  );
endmodule
