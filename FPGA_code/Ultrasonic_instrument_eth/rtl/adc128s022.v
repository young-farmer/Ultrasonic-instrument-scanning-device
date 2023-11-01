`timescale 1ns/1ns

module adc128s022(
	Clk,
	Rst_n,
	ad_otr,
	

	Data,
	
	En_Conv,
	Conv_Done,

	
	ad_clk,
	DOUT


);
	input ad_otr;

	input Clk;	//输入时钟
	input Rst_n; //复位输入，低电平复位
	output ad_clk;

	output reg [7:0]Data;	//ADC转换结果
	
	input En_Conv;	//使能单次转换，该信号为单周期有效，高脉冲使能一次转换
	output reg Conv_Done;	//转换完成信号，完成转换后产生一个时钟周期的高脉冲


	


	input  [7:0]DOUT;		//ADC转换结果，由ADC输给FPGA

	
	
	reg en;//转换使能信号
	assign  ad_clk = ~Clk; 
	
/*
	always @(posedge Clk or negedge Rst_n) begin
    if(Rst_n == 1'b0)
        ad_clk <= 1'b0;
    else 
        ad_clk <= ~ad_clk; 
	end    
*/

	//产生使能转换信号
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		en  <= #1  1'b0;
	else if(En_Conv)
		en  <= #1  1'b1;
	else if(Conv_Done)
		en  <= #1  1'b0;
	else
		en  <= #1  en;
		

	//转换完成时，将转换结果输出到Data端口，同时产生一个时钟周期的高脉冲信号
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		Data <= 12'd0; 
		Conv_Done <= 1'b0;
	end else if(en)begin
		Data <= DOUT; 
		Conv_Done <= 1'b1;
	end else begin
		Data <= Data; 
		Conv_Done <= 1'b0;
	end
	


endmodule
