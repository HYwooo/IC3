`timescale 1ns / 1ns
// 输 出 y[n]=0.5*x[n]+0.31*x[n-1]+0.63*x[n-2] 。 其中x[n],x[n-1],x[n-2]为 3 位二进制整数，计算结果用十进制数显示、保留一位小数
//      100y[n]=50*x[n]+(32-1)*x[n-1]+(64-1)*x[n-2] 
//7Q4 小数点后二进制数有4位 别搁着Q4了
module FIR_Filter_Core (
    input i_clk,  // 时钟
    input i_rst_n,  // 复位键，低电平有效
    input logic [2:0] Xin,  // 滤波器的输入数据
    output logic [11:0] Yout  // 滤波器的输出数据
);
  logic [2:0] Xin0, Xin1, Xin2;
  logic [11:0] Preout;
  // 将输入数据存入移位寄存器中
  always @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      Xin0 <= 'd0;
      Xin1 <= 'd0;
      Xin2 <= 'd0;
      Yout <= 'd0;
    end else begin
      if (|Xin) begin  //Xin按位或
        Xin2 <= Xin1;  // 表示把 x(n-1) 数据传递到 x(n-2)
        Xin1 <= Xin0;  // 表示把 x(n) 数据传递到 x(n-1)
        Xin0 <= Xin;
      end else begin  //输入无效或全为0时
        Xin2 <= Xin0;
        Xin1 <= Xin0;
        Xin0 <= 'd0;
      end
      //Xin=3'b100时，输出为 {2.0[0],3.2[4],5.7[6]}
      Preout<=( ({{3{1'b0}}, Xin0, {6{1'b0}}} + {{8{1'b0}}, Xin0, {1{1'b0}}} - {{5{1'b0}}, Xin0, {4{1'b0}}}) + ({{4{1'b0}}, Xin1, {5{1'b0}}} - Xin1) +  ({{3{1'b0}}, Xin2, {6{1'b0}}} - Xin2) );
      if (Preout[3:0] > 4) begin
        Yout <= Preout + 'd10;
      end else Yout <= Preout;
    end
endmodule
