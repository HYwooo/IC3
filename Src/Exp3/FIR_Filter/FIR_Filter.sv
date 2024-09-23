`timescale 1ns / 1ns
// �� �� y[n]=0.5*x[n]+0.31*x[n-1]+0.63*x[n-2] �� ����x[n],x[n-1],x[n-2]Ϊ 3 λ��������������������ʮ��������ʾ������һλС��
//7Q4 С��������������4λ
module FIR_Filter (
    input clk,  // ϵͳʱ��
    input rst_n,  // ��λ�����͵�ƽ��Ч
    input signed [2:0] Xin,  // �˲������������ݣ���������
    output reg signed [6:0] Yout  // �˲������������
);
  reg signed [2:0] Xin0, Xin1, Xin2;
  // ���������ݴ�����λ�Ĵ�����
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      Xin0 <= 'd0;
      Xin1 <= 'd0;
      Xin2 <= 'd0;
    end else begin
      if (|Xin) begin  //Xin��λ��
        Xin2 = Xin1;  // ��ʾ�� x(n-1) ���ݴ��ݵ� x(n-2)
        Xin1 = Xin0;  // ��ʾ�� x(n) ���ݴ��ݵ� x(n-1)
        Xin0 = Xin;
      end else begin  //������Ч��ȫΪ0ʱ
        Xin2 = Xin0;
        Xin1 = Xin0;
        Xin0 = 'd0;
      end
      //��16��Ϊ�� ��С��������4λ
      Yout <= 16 * (0.5 * Xin0 + 0.31 * Xin1 + 0.63 * Xin2);
    end
endmodule
