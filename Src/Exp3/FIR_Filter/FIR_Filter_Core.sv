`timescale 1ns / 1ns
// �� �� y[n]=0.5*x[n]+0.31*x[n-1]+0.63*x[n-2] �� ����x[n],x[n-1],x[n-2]Ϊ 3 λ��������������������ʮ��������ʾ������һλС��
//      100y[n]=50*x[n]+(32-1)*x[n-1]+(64-1)*x[n-2] 
//7Q4 С��������������4λ �����Q4��
module FIR_Filter_Core (
    input i_clk,  // ʱ��
    input i_rst_n,  // ��λ�����͵�ƽ��Ч
    input logic [2:0] Xin,  // �˲�������������
    output logic [11:0] Yout  // �˲������������
);
  logic [2:0] Xin0, Xin1, Xin2;
  logic [11:0] Preout;
  // ���������ݴ�����λ�Ĵ�����
  always @(posedge i_clk or negedge i_rst_n)
    if (!i_rst_n) begin
      Xin0 <= 'd0;
      Xin1 <= 'd0;
      Xin2 <= 'd0;
      Yout <= 'd0;
    end else begin
      if (|Xin) begin  //Xin��λ��
        Xin2 <= Xin1;  // ��ʾ�� x(n-1) ���ݴ��ݵ� x(n-2)
        Xin1 <= Xin0;  // ��ʾ�� x(n) ���ݴ��ݵ� x(n-1)
        Xin0 <= Xin;
      end else begin  //������Ч��ȫΪ0ʱ
        Xin2 <= Xin0;
        Xin1 <= Xin0;
        Xin0 <= 'd0;
      end
      //Xin=3'b100ʱ�����Ϊ {2.0[0],3.2[4],5.7[6]}
      Preout<=( ({{3{1'b0}}, Xin0, {6{1'b0}}} + {{8{1'b0}}, Xin0, {1{1'b0}}} - {{5{1'b0}}, Xin0, {4{1'b0}}}) + ({{4{1'b0}}, Xin1, {5{1'b0}}} - Xin1) +  ({{3{1'b0}}, Xin2, {6{1'b0}}} - Xin2) );
      if (Preout[3:0] > 4) begin
        Yout <= Preout + 'd10;
      end else Yout <= Preout;
    end
endmodule
