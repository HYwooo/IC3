// 输 出 y[n]=0.5*x[n]+0.31*x[n-1]+0.63*x[n-2] 。 其中x[n],x[n-1],x[n-2]为 3 位二进制整数，计算结果用十进制数显示、保留一位小数
//      100y[n]=50x[n]+31x[n-1]+63x[n-2]    
//*****************************************************
module FIR_Filter(
        input sys_clk, // 系统时钟
        input sys_rst_n, // 复位键，低电平有效
        input signed [2:0] Xin, // 滤波器的输入数据，输入速率
        output signed [2:0] Yout // 滤波器的输出数据
);
//*****************************************************
// 零点系数的实现
//*****************************************************
// 设置两个寄存器表示 x(n-1) 和 x(n-2)
reg signed[11:0] Xin0,Xin1, Xin2;
// 将输入数据存入移位寄存器中
always @(posedge sys_clk_n or negedge sys_rst_n)
    if (!sys_rst_n)
        begin
            Xin0 <= 12'd0;
            Xin1 <= 12'd0;
            Xin2 <= 12'd0;
        end
    else
        begin
        if(|Xin)             //Xin按位或
            begin
                Xin2 = Xin1; // 表示把 x(n-1) 数据传递到 x(n-2)
                Xin1 = Xin0; // 表示把 x(n) 数据传递到 x(n-1)
                Xin0 = Xin; 
            end
        else                 //输入无效或全为0时
            begin
                Xin2 = Xin0;  
                Xin1 = Xin0; 
                Xin0 = 12'd0;  
            end
        end
// 采用移位运算和加减法运算实现乘法
wire signed [23:0] XMult0, XMult1, XMult2;
// 94*x(n)，其中94=64+32-2，可以用左移6bit，加上左移5bit，减去左移1bit来实现
assign XMult0 = {{6{Xin0[11]}}, Xin0, 6'd0} + {{7{Xin0[11]}}, Xin0, 5'd0} - {{11{Xin0[11]}}, Xin0, 1'd0};
// 140*x(n-1)，其中140=128+8+4，可以用左移7bit，加上左移3bit，加上左移2bit来实现
assign XMult1 = {{5{Xin1[11]}}, Xin1, 7'd0} + {{9{Xin1[11]}}, Xin1, 3'd0} + {{10{Xin1[11]}}, Xin1, 2'd0};
// 94*x(n-2)，其中94=64+32-2，可以用左移6bit，加上左移5bit，减去左移1bit来实现
assign XMult2 = {{6{Xin2[11]}}, Xin2, 6'd0} + {{7{Xin2[11]}}, Xin2, 5'd0} - {{11{Xin2[11]}}, Xin2, 1'd0};
// 对滤波器系数与输入数据乘法结果进行累加
wire signed [23:0] Xout;
// Xout = 94*x(n) + 140*x(n-1) + 94*x(n-2)
assign Xout = XMult0 + XMult1 + XMult2;


reg signed[11:0] Yout1, Yout2;
always @(posedge sys_clk or negedge sys_rst_n)
    if (!sys_rst_n)
        begin
            Yout1 <= 12'd0;
            Yout2 <= 12'd0;
        end
    else
        begin
                Yout1 <= Yout; 
                Yout2 <= Yout1; 
        end
wire signed [23:0] YMult1, YMult2;
//10+7+5+4+3+2+0
assign YMult1 = {{2{Yout1[11]}}, Yout1, 10'd0} + {{5{Yout1[11]}}, Yout1, 7'd0} + {{7{Yout1[11]}}, Yout1, 5'd0}+ {{8{Yout1[11]}}, Yout1, 4'd0}+ {{9{Yout1[11]}}, Yout1, 3'd0}+ {{10{Yout1[11]}}, Yout1, 2'd0}+ {{12{Yout1[11]}}, Yout1};
//-(8+3+2)
assign YMult2 = -{{4{Yout1[11]}}, Yout1, 8'd0} - {{9{Yout1[11]}}, Yout1, 3'd0} - {{10{Yout1[11]}}, Yout1, 2'd0};

wire signed [23:0] Ytmp,Ysum;
assign Ytmp = YMult1 + YMult2;
assign Ysum = Xout+Ytmp;
//  /2048
wire signed [23:0] Ydiv = {{11{Ysum[23]}},Ysum[23:11]};
assign Yout = Ydiv[11:0];



endmodule