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
  logic clk_1kHz, clk_50Hz, clk_1Hz;
  logic [2:0] Xin = '0;  // 滤波器的输入数据，输入速率
  logic [11:0] Yout;  // 滤波器的输出数据
  logic [4:0] dig_ctrl;  //控制每个LED的显示内容 -> 0_X w/o dot,1_X w/ dot
  logic [2:0] cs_pointer;  //0~7
  logic [4:0] digits[3:0];  //5bit 2个数码管 其中两个是debug时显示cnt用的
  logic [8:0] key_state;
  //bin2bcd转换数字
  logic [13:0] bin;
  logic [15:0] bcd;
  ///
  assign bin = {{2{1'b0}}, Yout};
  //T'触发器
  always @(negedge key_state[5]) begin
    Xin[2]   <= ~Xin[2];
    o_led[1] <= ~Xin[2];
  end
  always @(negedge key_state[4]) begin
    Xin[1]   <= ~Xin[1];
    o_led[2] <= ~Xin[1];
  end
  always @(negedge key_state[3]) begin
    Xin[0]   <= ~Xin[0];
    o_led[3] <= ~Xin[0];
  end
  always @(posedge clk_50Hz) begin
    digits[0] <= bcd[15:12];
    digits[1] <= bcd[11:8] | 5'b1_0000;
    digits[2] <= bcd[7:4];
  end
  //1kHz扫描片选
  always @(posedge clk_50Hz) begin
    if (cs_pointer & 3'b010) cs_pointer <= 0;  //
    else cs_pointer <= cs_pointer + 1;
  end
  //组合逻辑实现pointer到译码器的映射 将digits(bin)输入到译码器
  always_comb begin
    dig_ctrl = digits[cs_pointer];
  end
  bin2bcd bin2bcd_inst (
      .i_bin(bin),
      .o_bcd(bcd)
  );
  //按钮消抖
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 1) begin : Gen_Debouncer
      if (i < 1 || i > 2) begin
        SimpleDebouncer Debouncer_inst (
            .i_clk_50Hz(clk_50Hz),
            .i_rst_n(i_rst_n),
            .i_key(i_key[i]),
            .o_key_state(key_state[i])
        );
      end
    end
  endgenerate
  //FIR滤波器核心
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
  /* Divider #(
      .DIV_NUM(F_CLK / F_CLK_SLOW),
      .DUTY(F_CLK / F_CLK_SLOW / 2)
  ) CLK50Mto1k (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  ); */
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
