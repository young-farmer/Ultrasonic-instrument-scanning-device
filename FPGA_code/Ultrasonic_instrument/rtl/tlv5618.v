`timescale 1ns/1ns
/*============================================================================
*
DA芯片：接收DDS模块信号，通过DIN传输到外部接口
===========================================================================*/
module tlv5618(
	Clk,
	DAC_DATA,
	DIN,
	daCLK

);

	input Clk;
	input [7:0]DAC_DATA;	
	output[7:0]DIN;
	output daCLK;
assign  daCLK = ~Clk;       
assign  DIN = DAC_DATA; 


	
endmodule
