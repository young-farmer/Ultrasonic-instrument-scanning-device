/*============================================================================
*
*检测设备FPGA顶层模块
===========================================================================*/

module top_level(
	Clk,
	Rst_n,
	Rs232_Rx,
	Rs232_Tx,
	Key_in,
	led,
	in_a,
	in_b,
	ADC_SCLK,
	ADC_DOUT,
	ADC_SCLK_1,
	ADC_DOUT_1,
	DAC_DIN,
	DAC_SCLK,
	led_out,
	
	eth_rxc,
	eth_rxd,
	eth_rxdv,
	requs,
	

	eth_gtxc,
	eth_txd,
	eth_txen,
	eth_rst_n,
	eth_mdc,
	eth_mdio
);
	
//###################################################################################################

	   //eth receive interface
	input eth_rxc; //以太网接收时钟
	input [3:0] eth_rxd; //以太网接收数据
	input eth_rxdv; //以太网接收数据有效标志
	
	//eth send interface
	output eth_gtxc; //以太网发送时钟
	output [3:0] eth_txd; //以太网发送数据
	output eth_txen; //以太网发送数据有效标志
	
	// mdio
	output eth_rst_n; //以太网复位，低有效
	inout eth_mdc;
	inout eth_mdio;
	output ADC_SCLK_1;	//ADC 串行数据接口时钟信号
	  //ADC 串行数据接口使能信号
	input  [7:0]ADC_DOUT_1;		//ADC转换结果，由ADC输给FPGA
		//ADC控制信号输出，由FPGA发送通道控制字给ADC
	output [7:0]requs;
	

   
   

	 
//###################################################################################################
	

	input Clk;	/*系统时钟，50M*/
	input Rst_n;	/*全局复位，低电平复位*/
	input Rs232_Rx;	/*串口接收引脚*/
	output Rs232_Tx;	/*串口发送引脚*/
	output led_out;
	input [1:0]Key_in;	/*按键输入*/
	input in_a;		/*编码器输入*/
	input in_b;		/*编码器输入*/
	
	
	output ADC_SCLK;	//ADC 串行数据接口时钟信号
	  //ADC 串行数据接口使能信号
	input  [7:0]ADC_DOUT;		//ADC转换结果，由ADC输给FPGA
		//ADC控制信号输出，由FPGA发送通道控制字给ADC
	
	
	output [7:0]DAC_DIN; 
	output DAC_SCLK;
	
	
	
	
		
	//LED
	output [1:0]led;

	//ADC



	
	
	
	wire [7:0]cmd_addr;
   wire [31:0]cmd_data;
   wire cmdvalid;
	 
	wire [1:0]adc_ch_sel;
	
	
	wire [15:0]ad_out;
   wire ad_out_valid;
	
	
	wire [7:0]position_date;
	
	reg [2:0]ADC_Channel;

	wire [2:0]Baud_Set; /*波特率设置信号*/
	
	wire [7:0]Rx_Byte;	/*串口接收到的字节数据*/
	wire Rx_Int;		/*串口接收字节成功标志信号*/
	
	wire Byte_En;	 	/*串口字节数据发送使能信号*/
	wire Tx_Done;		/*串口发送字节数据完成标志*/
	
	wire ADC_En;		/*ADC单次转换使能信号*/
	//wire [11:0]ADC_Data;	/*ADC采样结果*/
	wire ADC_Flag;		/*ADC转换结果有效标志*/
	wire ADC_Busy;		/*ADC工作忙标志*/
	
	wire m_wr;	/*主机写数据的请求*/
	wire [7:0]m_addr;	/*主机写数据的地址*/
	wire [15:0]m_wrdata;	/*主机写数据*/
	
	
	wire [11:0]DDS_Data;	/*DDS生成的波形数据*/
	wire DDS_Flag;	/*DDS采样使能标志*/
	
	wire Data_Flag;	/*数据有效标志（根据用户按键进行选择DDS_Flag 或ADC_Flag）*/
	wire Uart_Flag;	/*数据有效标志（根据用户按键进行选择DDS_Flag 或ADC_Flag）*/
	//wire [7:0]Data_Byte;/*串口发送字节数据*/
	wire [7:0]date_out;

	reg ad_clk;
	reg Data_Sel;	/*数据选择信号（选择串口发送DDS_Data 或 ADC_Data）*/
	reg Flag_Sel;	/*数据有效标志信号选择信号（选择DDS_Flag 或ADC_Flag）*/
	
	wire [1:0]Key_Flag;	/*按键检测成功标志信号*/
	wire [1:0]Key_Value;	/*按键检测结果*/
	


	assign requs = (requs1)?7'd0:7'd200;

	assign ADC_SCLK = Clk;
	assign ADC_SCLK_1 = Clk;
	
	AD9226_RGMII AD9226_RGMII
	(
		 .Clk(Clk),
		 .reset_n(Rst_n),

		 .eth_rxc(eth_rxc),
		 .eth_rxd(eth_txd),
		 .eth_rxdv(eth_rxdv),
		
		 .ad_in1(ADC_DOUT),
		 .ad_in2(ADC_DOUT_1),
		 .ad_clk1(ADC_SCLK),
		 .ad_clk2(ADC_SCLK_1),
	 
		

		 .eth_gtxc(eth_gtxc),
		 .eth_txd(eth_txd),
		 .eth_txen(eth_txen),
		 .eth_rst_n(eth_rst_n),
		 .eth_mdc(eth_mdc),
		 .eth_mdio(eth_mdio)
	
	);


  
	 


	
	
	
	

	encode encode(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.in_a(in_a),
		.in_b(in_b),
		.position(position_date)
		
	);


/*-----------例化串口字节接收模块-------*/	
	Uart_Byte_Rx Uart_Byte_Rx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Baud_Set(Baud_Set),
		.Rs232_Rx(Rs232_Rx),
		.Rx_Byte(Rx_Byte),
		.Rx_Done(Rx_Int)
	);
	
/*-----------例化串口接收到的命令解析模块-------*/	
	CMD CMD(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Rx_Byte(Rx_Byte),
		.Rx_Int(Rx_Int),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata)
	);

/*-----------例化串口字节发送模块-------*/		
	UART_Byte_Tx UART_Byte_Tx(	
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Byte_En(Byte_En),
		.Baud_Set(Baud_Set),
		.Data_Byte(position_date),
		.Tx_Done(Tx_Done),
		.Rs232_Tx(Rs232_Tx)
	);
	
/*-----------例化串口字节发送控制模块-------*/	
	UART_Tx_Ctrl UART_Tx_Ctrl(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata),
		.ADC_Flag(Data_Flag),
		.Byte_En(Byte_En),
		.Tx_Done(Tx_Done),
		.Baud_Set(Baud_Set)
	);




/*-----------例化DDS信号发生器模块-------*/	
	DDS DDS(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata),
		.DDS_Data(DDS_Data),
		.DDS_Flag(DDS_Flag),
		.Uart_Flag(Uart_Flag),
		.EN_11(requs1)
	);

/*-----------例化DAC信号发生器模块-------*/	
	tlv5618 tlv5618(
		.Clk(Clk),
		.DAC_DATA(DDS_Data[11:4]),
		.DIN(DAC_DIN),
		.daCLK(DAC_SCLK)
	);

/*-----------例化独立按键检测消抖模块-------*/		
	key_filter key_filter0(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.key_in(Key_in[0]),
		.key_flag(Key_Flag[0]),
		.key_state(Key_Value[0])
	);

	key_filter key_filter1(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.key_in(Key_in[1]),
		.key_flag(Key_Flag[1]),
		.key_state(Key_Value[1])
	);
	
/*-----------通道选择模块-------*/

	ch_sel ch_sel(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata),
		.ch_sel(adc_ch_sel)
	);

/*串口待发送字节数据选择二选一多路器*/	
	//assign Data_Byte = ADC_Data;
	
/*串口待发送字节数据有效标志二选一多路器*/	
	assign Data_Flag = Uart_Flag;

/*根据用户按键动作选择数据和标志信号多路器通道*/	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		Data_Sel <= 1'b1;
		Flag_Sel <= 1'b1;
	end
	else if(Key_Flag && (Key_Value == 2'b01))begin
		Data_Sel <= ~Data_Sel;
		Flag_Sel <= ~Flag_Sel;
	end
	else begin
		Data_Sel <= Data_Sel;
		Flag_Sel <= Flag_Sel;	
	end
		

		
endmodule
