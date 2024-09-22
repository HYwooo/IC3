// �� �� y[n]=0.5*x[n]+0.31*x[n-1]+0.63*x[n-2] �� ����x[n],x[n-1],x[n-2]Ϊ 3 λ��������������������ʮ��������ʾ������һλС��
//      100y[n]=50x[n]+31x[n-1]+63x[n-2]    
//*****************************************************
module FIR_Filter(
        input sys_clk, // ϵͳʱ��
        input sys_rst_n, // ��λ�����͵�ƽ��Ч
        input signed [2:0] Xin, // �˲������������ݣ���������
        output signed [2:0] Yout // �˲������������
);
//*****************************************************
// ���ϵ����ʵ��
//*****************************************************
// ���������Ĵ�����ʾ x(n-1) �� x(n-2)
reg signed[11:0] Xin0,Xin1, Xin2;
// ���������ݴ�����λ�Ĵ�����
always @(posedge sys_clk_n or negedge sys_rst_n)
    if (!sys_rst_n)
        begin
            Xin0 <= 12'd0;
            Xin1 <= 12'd0;
            Xin2 <= 12'd0;
        end
    else
        begin
        if(|Xin)             //Xin��λ��
            begin
                Xin2 = Xin1; // ��ʾ�� x(n-1) ���ݴ��ݵ� x(n-2)
                Xin1 = Xin0; // ��ʾ�� x(n) ���ݴ��ݵ� x(n-1)
                Xin0 = Xin; 
            end
        else                 //������Ч��ȫΪ0ʱ
            begin
                Xin2 = Xin0;  
                Xin1 = Xin0; 
                Xin0 = 12'd0;  
            end
        end
// ������λ����ͼӼ�������ʵ�ֳ˷�
wire signed [23:0] XMult0, XMult1, XMult2;
// 94*x(n)������94=64+32-2������������6bit����������5bit����ȥ����1bit��ʵ��
assign XMult0 = {{6{Xin0[11]}}, Xin0, 6'd0} + {{7{Xin0[11]}}, Xin0, 5'd0} - {{11{Xin0[11]}}, Xin0, 1'd0};
// 140*x(n-1)������140=128+8+4������������7bit����������3bit����������2bit��ʵ��
assign XMult1 = {{5{Xin1[11]}}, Xin1, 7'd0} + {{9{Xin1[11]}}, Xin1, 3'd0} + {{10{Xin1[11]}}, Xin1, 2'd0};
// 94*x(n-2)������94=64+32-2������������6bit����������5bit����ȥ����1bit��ʵ��
assign XMult2 = {{6{Xin2[11]}}, Xin2, 6'd0} + {{7{Xin2[11]}}, Xin2, 5'd0} - {{11{Xin2[11]}}, Xin2, 1'd0};
// ���˲���ϵ�����������ݳ˷���������ۼ�
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