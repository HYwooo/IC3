module LED_Decoder (
    input [4:0] seg_ctrl,  // 5 位输入，用于选择 7 段数码管的显示内容，最高位为小数点控制位
    output reg [7:0] seg_valid  // 8 位输出，用于控制 7 段数码管（加小数点）的显示内容
);
  always_comb begin  //decoder for seven_segment
    case (seg_ctrl)
      5'h00: seg_valid = 8'h3f;  //"0"
      5'h01: seg_valid = 8'h06;  //"1"
      5'h02: seg_valid = 8'h5b;  //"2"
      5'h03: seg_valid = 8'h4f;  //"3"
      5'h04: seg_valid = 8'h66;  //"4"
      5'h05: seg_valid = 8'h6d;  //"5"
      5'h06: seg_valid = 8'h7d;  //"6"
      5'h07: seg_valid = 8'h07;  //"7"
      5'h08: seg_valid = 8'h7f;  //"8"
      5'h09: seg_valid = 8'h6f;  //"9"
      5'h0a: seg_valid = 8'h77;  //"A"
      5'h0b: seg_valid = 8'h7c;  //"B"
      5'h0c: seg_valid = 8'h39;  //"C"
      5'h0d: seg_valid = 8'h5e;  //"D"
      5'h0e: seg_valid = 8'h79;  //"E"
      5'h0f: seg_valid = 8'h71;  //"F"
      5'h10: seg_valid = 8'h3f + 8'h80; //"0."
      5'h11: seg_valid = 8'h06 + 8'h80; //"1."
      5'h12: seg_valid = 8'h5b + 8'h80; //"2."
      5'h13: seg_valid = 8'h4f + 8'h80; //"3."
      5'h14: seg_valid = 8'h66 + 8'h80; //"4."
      5'h15: seg_valid = 8'h6d + 8'h80; //"5."
      5'h16: seg_valid = 8'h7d + 8'h80; //"6."
      5'h17: seg_valid = 8'h07 + 8'h80; //"7."
      5'h18: seg_valid = 8'h7f + 8'h80; //"8."
      5'h19: seg_valid = 8'h6f + 8'h80; //"9."
      5'h1a: seg_valid = 8'h77 + 8'h80; //"A."
      5'h1b: seg_valid = 8'h7c + 8'h80; //"B."
      5'h1c: seg_valid = 8'h39 + 8'h80; //"C."
      5'h1d: seg_valid = 8'h5e + 8'h80; //"D."
      5'h1e: seg_valid = 8'h79 + 8'h80; //"E."
      5'h1f: seg_valid = 8'h71 + 8'h80; //"F."
      default: seg_valid = 8'hFF;  //default:全亮
    endcase
  end
endmodule
