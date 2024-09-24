//LED_CS.sv
//译码器，生成片选信号
module LED_CS (
    input rst_n,
    input [2:0] cs_pointer,
    output logic [7:0] cs
);
  always @(*) begin
    if (!rst_n) begin
      cs = 8'hFF;  //全选
    end else begin
      unique case (cs_pointer)
        3'd0: cs = 8'b0000_0001;
        3'd1: cs = 8'b0000_0010;
        3'd2: cs = 8'b0000_0100;
        3'd3: cs = 8'b0000_1000;
        3'd4: cs = 8'b0001_0000;
        3'd5: cs = 8'b0010_0000;
        3'd6: cs = 8'b0100_0000;
        3'd7: cs = 8'b1000_0000;
        default: cs = 8'b1111_1111;
      endcase
    end
  end
endmodule
