module bin2bcd (
    input [13:0] i_bin,
    output reg [15:0] o_bcd
);
  integer i;
  always @(i_bin) begin
    o_bcd = 0;
    for (i = 0; i < 14; i = i + 1) begin  //Iterate once for each bit in input number
      if (o_bcd[3:0] >= 5) o_bcd[3:0] = o_bcd[3:0] + 3;  //If any BCD digit is >= 5, add three
      if (o_bcd[7:4] >= 5) o_bcd[7:4] = o_bcd[7:4] + 3;
      if (o_bcd[11:8] >= 5) o_bcd[11:8] = o_bcd[11:8] + 3;
      if (o_bcd[15:12] >= 5) o_bcd[15:12] = o_bcd[15:12] + 3;
      o_bcd = {o_bcd[14:0], i_bin[13-i]};  //Shift one bit, and shift in proper bit from input 
    end
  end
endmodule
