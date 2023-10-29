/*============================================================================
*
*  LOGIC CORE:          直接数字合成（DDS）信号发生器模块		
*  MODULE NAME:         DDS_Module()
*  COMPANY:             芯航线电子工作室
*                       http://xiaomeige.taobao.com
*	author:					小梅哥
*	author QQ Group：472607506
*  REVISION HISTORY:  
*
*    Revision 1.0  01/01/2016     Description: Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
*	本模块为直接数字合成（DDS）信号发生器模块
===========================================================================*/
module DDS_Module(
		Clk,
		Rst_n,
		EN,
		Fword,
		Pword,
		DA_Clk,
		DA_Data
	);

	input Clk;/*系统时钟*/
	input Rst_n;/*系统复位*/
	input EN;/*DDS模块使能*/
	input [31:0]Fword;/*频率控制字*/
	input [11:0]Pword;/*相位控制字*/
	
	output DA_Clk;/*DA数据输出时钟*/
	output [9:0]DA_Data;/*D输出输出A*/
	
	reg [31:0]Fre_acc;	
	reg [11:0]Rom_Addr;
	wire [11:0]Rom_Addr_r;
	reg [15:0]count;
	reg EN_1;


/*---------------相位累加器------------------*/	
	always @(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Fre_acc <= 32'd0;
	else if(!EN_1)
		Fre_acc <= 32'd0;	
	else 
		Fre_acc <= Fre_acc + Fword;

/*----------生成查找表地址---------------------*/		
	always @(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Rom_Addr <= 12'd0;
	else if(!EN_1)
		Rom_Addr <= 12'd0;
	else
		Rom_Addr <= Fre_acc[31:20] + Pword;	

	always @(posedge Clk or negedge Rst_n) 
	if (!Rst_n) begin
		count <= 0;
		EN_1 <= 0;
	end 
	else begin
		count <= count + 1;
		if (count >= 65000)  // 100个时钟周期后，将out设置为1
			EN_1 <= 1;
		else 
			EN_1 <= 0;
	end


/*----------例化查找表ROM-------*/		
	ddsrom ddsrom(
		.address(Rom_Addr_r),
		.clock(Clk),
		.q(DA_Data)
	);

/*----------输出DA时钟----------*/	
	assign DA_Clk = (EN)?Clk:1'b1;
	assign Rom_Addr_r = (EN_1)?Rom_Addr:1'b0;

endmodule
