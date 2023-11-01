module ch_sel(
	Clk,
	Rst_n,
	m_wr,
	m_addr,
	m_wrdata,
	ch_sel



);
	input Clk;
	input Rst_n;
	input m_wr;				/*主机写寄存器请求*/
	input [7:0]m_addr;	/*主机写寄存器地址*/
	input [15:0]m_wrdata;/*主机写寄存器数据*/
	output reg [1:0]ch_sel;	/*信号通道选择*/


	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		ch_sel <= 2'b01;
	end
	else if(m_wr && (m_addr == `data_ch_sel))
		ch_sel <= m_wrdata;
	else begin
		ch_sel <= ch_sel;
	end
endmodule