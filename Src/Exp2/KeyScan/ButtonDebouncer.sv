//ButtonDebouncer.sv
//使用FSM实现按键消抖
module ButtonDebouncer #(
    parameter F_CLK = 50000000,
    parameter F_CLK_DIV = 1000
) (
    input i_clk,
    input i_rst_n,
    input i_key,
    output logic o_key_state
);
  logic clk_1kHz;

  localparam STATE_IDLE = 1'd0, STATE_PRESSED = 1'd1;
  logic state, next_state;
  logic [4:0] cnt;
  //FSM
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state <= STATE_IDLE;
    end else state <= next_state;
  end
  always @(posedge clk_1kHz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cnt <= 0;
      next_state <= STATE_IDLE;
    end else begin
      if (state == STATE_IDLE) begin
        if (!i_key) begin
          cnt <= cnt + 1;
          if (cnt == 20) next_state <= STATE_PRESSED;
        end else cnt <= 0;
      end else begin
        if (i_key) begin
          cnt <= cnt + 1;
          if (cnt == 20) next_state <= STATE_IDLE;
        end else cnt <= 0;
      end
    end
  end
  assign o_key_state = ~state;
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_DIV),
      .DUTY(F_CLK / F_CLK_DIV / 2)
  ) CLK50Mto1k (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .o_clk_div(clk_1kHz)
  );
endmodule
