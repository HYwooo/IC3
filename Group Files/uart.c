// 使用 Xilinx SDK Terminal, putty 等串口调试程序，返回输入的字符串
// 字符串操作
#include <string.h>
// XSDK 生成的宏，可以快速找到设备的地址（按住 CTRL 可打开）
#include <xparameters.h>
// XSDK 定义的宏，u32 由其定义
#include <xil_types.h>
#define UART_RX_FIFO XPAR_AXI_UARTLITE_0_BASEADDR
#define UART_TX_FIFO XPAR_AXI_UARTLITE_0_BASEADDR + 0x00000004
#define UART_STAT XPAR_AXI_UARTLITE_0_BASEADDR + 0x00000008
#define UART_CTRL XPAR_AXI_UARTLITE_0_BASEADDR + 0x0000000c

// 根据文档 AXI UART Lite v2.0 （PG142）编写下面的掩码，
// 通过掩码可以操作对应的寄存器的位

#define UART_TX_FULL_MASK 0x00000008
#define UART_TX_EMPTY_MASK 0x00000004
#define UART_RX_FULL_MASK 0x00000002
#define UART_RX_VALID_MASK 0x00000001
#define UART_RX_CLEAR_MASK 0x00000002
#define UART_TX_CLEAR_MASK 0x00000001

// 通过 UART 打印字符串
// 注意，粗略地限制了 128 个字符，因此如果没有 \0，字符数组的打印可能出现异常。

void uart_puts(char *ch)
{
	int index = 0;
	while (index < 128)
	{
		if (((*(u32 *)(UART_STAT)) & UART_TX_FULL_MASK) == 0)
		{
			if (ch[index] == '\0') // End of a string
			{
				break;
			}
			*(u32 *)(UART_TX_FIFO) = ch[index];
			index++;
		}
		else
		{
			// 等待发送 FIFO 不为满，避免数据被覆盖
		}
	}
}

// 通过 UART 获取字符串
// 需要给定字符数组的地址和获取的字节数
void uart_gets(char *buff, int numBytes)
{
	int index = 0;
	while (index < numBytes)
	{
		if (((*(u32 *)(UART_STAT)) & UART_RX_VALID_MASK))
		{
			buff[index] = *(u32 *)(UART_RX_FIFO);
			if (buff[index] == '\n' || buff[index] == '\r')
			{
				buff[index] = '\0';
				break;
			}
			index++;
		}
		else
		{
			// 等待输入
		}
	}
}

int main()
{
	uart_puts("\n*** UART demo: echo server ***\n");
	char rx_buff[50] = {0};
	char tx_buff[50] = {0};
	while (1)
	{
		uart_puts("\nIn: ");
		uart_gets(rx_buff, 50);
		strcpy(tx_buff, "\nOut: ");
		strcat(tx_buff, rx_buff);
		uart_puts(tx_buff);
		uart_puts("\n");
	}
	return 0;
}