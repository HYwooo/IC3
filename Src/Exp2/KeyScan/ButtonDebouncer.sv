//ButtonDebouncer.sv
//使用FSM实现按键消抖
module ButtonDebouncer #(
    parameter F_CLK = 50000000,
    parameter F_CLK_DIV = 1000
) (
    input clk,
    input rst_n,
    input key,
    output logic key_state
);
  logic clk_1kHz;

  localparam STATE_IDLE = 1'd0,  // initial state
  STATE_PRESSED = 1'd1;
  logic state, next_state;
  logic [4:0] cnt;
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      state <= STATE_IDLE;
    end else state <= next_state;
  end
  always @(posedge clk_1kHz or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 0;
      next_state <= STATE_IDLE;
    end else begin
      if (state == STATE_IDLE) begin
        if (!key) begin
          cnt <= cnt + 1;
          if (cnt == 20) begin
            next_state <= STATE_PRESSED;
          end
        end else begin
          cnt <= 0;
        end
      end else begin
        if (key) begin
          cnt <= cnt + 1;
          if (cnt == 20) begin
            next_state <= STATE_IDLE;
          end
        end else begin
          cnt <= 0;
        end
      end
    end
  end
  assign key_state = ~state;
  Divider #(
      .DIV_NUM(F_CLK / F_CLK_DIV),
      .DUTY(F_CLK / F_CLK_DIV / 2)
  ) CLK50Mto1k (
      .clk(clk),
      .rst_n(rst_n),
      .clk_div(clk_1kHz)
  );
endmodule
