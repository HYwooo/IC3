
module KeyboardToDigits (
    input i_clk,
    input i_rst_n,
    input logic [3:0] i_key_col,
    
    output logic [3:0] o_key_row,
    output logic [3:0] o_led,  //[0]red [1]yellow [2]green
    output logic [7:0] o_cs,  //片选信号
    output logic [7:0] o_dig_sel
);
    
endmodule