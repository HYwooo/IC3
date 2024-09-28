//SimpleDebouncer.sv
module SimpleDebouncer (
    input clk_50Hz,
    input rst_n,
    input key,
    output logic key_state
);
  always_ff @(posedge clk_50Hz or negedge rst_n) begin
    if (!rst_n) begin
      key_state <= 1'b1;
    end else begin
      key_state <= (key ^ key_state) & key;
    end
  end
endmodule
