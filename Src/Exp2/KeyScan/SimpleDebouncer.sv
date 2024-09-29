//SimpleDebouncer.sv
module SimpleDebouncer (
    input i_clk_50Hz,
    input i_rst_n,
    input logic i_key,
    output logic o_key_state
);
  always_ff @(posedge i_clk_50Hz or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_key_state <= 1'b1;
    end else begin
      o_key_state <=  i_key ;
    end
  end
endmodule
