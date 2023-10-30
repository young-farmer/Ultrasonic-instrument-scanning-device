
`include "../rtl/header.v"

module encode_Ctrl(
	Clk,
	Rst_n,
	
	date_in_encode,
	m_wr,
	m_addr,
	m_wrdata,
	date_out
);
	
	input Clk;
	input Rst_n;
	input m_wr;				/*主机写寄存器请求*/
	input [7:0]m_addr;	/*主机写寄存器地址*/
	input [15:0]m_wrdata;/*主机写寄存器数据*/
	
	
	input [7:0]date_in_encode;		/*编码器信号*/
	output reg [7:0]date_out;	/*串口发送信号*/


	
	reg En_Tx;	/*存储波形选择信号*/


/*---------写串口发送使能寄存器------------------*/	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		En_Tx <= 1'b0;
	else if(m_wr && (m_addr == `Date))
		En_Tx <= m_wrdata[0];
	else
		En_Tx <= En_Tx;	
	
/*---------写串口发送波特率设置寄存器-------------*/
	
	//assign date_out = date_in_encode;

	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		date_out <= 1'd0;
	else
		date_out <= date_in_encode;



endmodule
