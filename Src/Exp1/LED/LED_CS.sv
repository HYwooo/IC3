//LED_CS.sv
//译码器，生成片选信号
module LED_CS (
    input i_rst_n,
    input [2:0] cs_pointer,
    output logic [7:0] o_cs
);
  always @(*) begin
    if (!i_rst_n) begin
      o_cs = 8'hFF;  //全选
    end else begin
      unique case (cs_pointer)
        3'd0: o_cs = 8'b0000_0001;
        3'd1: o_cs = 8'b0000_0010;
        3'd2: o_cs = 8'b0000_0100;
        3'd3: o_cs = 8'b0000_1000;
        3'd4: o_cs = 8'b0001_0000;
        3'd5: o_cs = 8'b0010_0000;
        3'd6: o_cs = 8'b0100_0000;
        3'd7: o_cs = 8'b1000_0000;
        // default: o_cs = 8'b1111_1111;
      endcase
    end
  end
endmodule
