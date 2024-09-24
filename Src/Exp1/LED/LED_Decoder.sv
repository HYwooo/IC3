//LED_Decoder.sv
//用于将5位二进制输入转换为8位输出，用于控制7段数码管（及小数点）的显示内容
module LED_Decoder (
    input rst_n,
    input [4:0] dig_ctrl,  // 5 位输入，用于选择 7 段数码管的显示内容，最高位为小数点控制位
    output reg [7:0] o_dig_sel  // 8 位输出，用于控制 7 段数码管（加小数点）的显示内容
);
  logic [7:0] digit_code;
  assign o_dig_sel = ~digit_code;  //共阴极转共阳极
  always @(*) begin
    if (!rst_n) begin
      digit_code = 'h00;  //全灭
    end else begin
      unique case (dig_ctrl)
        5'h00:   digit_code = 8'h3f;  //"0"
        5'h01:   digit_code = 8'h06;  //"1"
        5'h02:   digit_code = 8'h5b;  //"2"
        5'h03:   digit_code = 8'h4f;  //"3"
        5'h04:   digit_code = 8'h66;  //"4"
        5'h05:   digit_code = 8'h6d;  //"5"
        5'h06:   digit_code = 8'h7d;  //"6"
        5'h07:   digit_code = 8'h07;  //"7"
        5'h08:   digit_code = 8'h7f;  //"8"
        5'h09:   digit_code = 8'h6f;  //"9"
        5'h0a:   digit_code = 8'h77;  //"A"
        5'h0b:   digit_code = 8'h7c;  //"B"
        5'h0c:   digit_code = 8'h39;  //"C"
        5'h0d:   digit_code = 8'h5e;  //"D"
        5'h0e:   digit_code = 8'h79;  //"E"
        5'h0f:   digit_code = 8'h71;  //"F"
        5'h10:   digit_code = 8'h3f | 8'h80;  //"0."
        5'h11:   digit_code = 8'h06 | 8'h80;  //"1."
        5'h12:   digit_code = 8'h5b | 8'h80;  //"2."
        5'h13:   digit_code = 8'h4f | 8'h80;  //"3."
        5'h14:   digit_code = 8'h66 | 8'h80;  //"4."
        5'h15:   digit_code = 8'h6d | 8'h80;  //"5."
        5'h16:   digit_code = 8'h7d | 8'h80;  //"6."
        5'h17:   digit_code = 8'h07 | 8'h80;  //"7."
        5'h18:   digit_code = 8'h7f | 8'h80;  //"8."
        5'h19:   digit_code = 8'h6f | 8'h80;  //"9."
        5'h1a:   digit_code = 8'h77 | 8'h80;  //"A."
        5'h1b:   digit_code = 8'h7c | 8'h80;  //"B."
        5'h1c:   digit_code = 8'h39 | 8'h80;  //"C."
        5'h1d:   digit_code = 8'h5e | 8'h80;  //"D."
        5'h1e:   digit_code = 8'h79 | 8'h80;  //"E."
        5'h1f:   digit_code = 8'h71 | 8'h80;  //"F."
        default: digit_code = 8'hFF;  //default:全亮
      endcase
    end
  end
endmodule
