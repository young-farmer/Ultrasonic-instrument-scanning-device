`timescale 1ns/1ns

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
