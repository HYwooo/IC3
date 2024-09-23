`timescale 1ns / 1ns
// 输 出 y[n]=0.5*x[n]+0.31*x[n-1]+0.63*x[n-2] 。 其中x[n],x[n-1],x[n-2]为 3 位二进制整数，计算结果用十进制数显示、保留一位小数
//7Q4 小数点后二进制数有4位
module FIR_Filter (
    input clk,  // 系统时钟
    input rst_n,  // 复位键，低电平有效
    input signed [2:0] Xin,  // 滤波器的输入数据，输入速率
    output reg signed [6:0] Yout  // 滤波器的输出数据
);
  reg signed [2:0] Xin0, Xin1, Xin2;
  // 将输入数据存入移位寄存器中
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      Xin0 <= 'd0;
      Xin1 <= 'd0;
      Xin2 <= 'd0;
    end else begin
      if (|Xin) begin  //Xin按位或
        Xin2 = Xin1;  // 表示把 x(n-1) 数据传递到 x(n-2)
        Xin1 = Xin0;  // 表示把 x(n) 数据传递到 x(n-1)
        Xin0 = Xin;
      end else begin  //输入无效或全为0时
        Xin2 = Xin0;
        Xin1 = Xin0;
        Xin0 = 'd0;
      end
      //乘16是为了 将小数点左移4位
      Yout <= 16 * (0.5 * Xin0 + 0.31 * Xin1 + 0.63 * Xin2);
    end
endmodule
