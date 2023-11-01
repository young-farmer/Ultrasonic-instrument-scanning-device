/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// 
// 
/////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module top_file(
	 Clk,
	 reset_n,

    eth_rxc,
	 eth_rxd,
	 eth_rxdv,
	 
	 Rs232_Rx,
	 Rs232_Tx,
	 Key_in,
	 led,
	 in_a,
	 in_b,
	
	 ad_in1,
    ad_in2,
	 ad_clk1,
	 ad_clk2,
 
	 
	 led,

	 eth_gtxc,
	 eth_txd,
	 eth_txen,
	 eth_rst_n,
	 eth_mdc,
	 eth_mdio,
	 
	 DAC_DIN,
	 DAC_SCLK,
	 requs
	 
	 );
	 
	 ////
	 wire [11:0]DDS_Data;	/*DDS生成的波形数据*/
	 output [7:0]DAC_DIN;/*激励输出*/
	 output DAC_SCLK;/*DA芯片时钟*/
	 wire m_wr;	/*主机写数据的请求*/
	 wire [7:0]m_addr;	/*主机写数据的地址*/
	 wire [15:0]m_wrdata;	/*主机写数据*/	
	 wire DDS_Flag;	/*DDS采样使能标志*/
	 wire Data_Flag;	/*数据有效标志（根据用户按键进行选择DDS_Flag 或ADC_Flag）*/
	 wire Byte_En;	 	/*串口字节数据发送使能信号*/
	 wire Tx_Done;		/*串口发送字节数据完成标志*/
	 wire [2:0]Baud_Set; /*波特率设置信号*/
    output Rs232_Tx;	/*串口发送引脚*/
	 wire [7:0]position_date;
	 input Rs232_Rx;	/*串口接收引脚*/
	 wire Rx_Int;		/*串口接收字节成功标志信号*/
	 wire [7:0]Rx_Byte;	/*串口接收到的字节数据*/
	 input [1:0]Key_in;	/*按键输入*/
	 input in_a;		/*编码器输入*/
	 input in_b;		/*编码器输入*/	
	 wire Uart_Flag;	/*数据有效标志（根据用户按键进行选择DDS_Flag 或ADC_Flag）*/
	 reg Data_Sel;	/*数据选择信号（选择串口发送DDS_Data 或 ADC_Data）*/
	 reg Flag_Sel;	/*数据有效标志信号选择信号（选择DDS_Flag 或ADC_Flag）*/
	 wire [1:0]Key_Flag;	/*按键检测成功标志信号*/
	 wire [1:0]Key_Value;	/*按键检测结果*/
	 output [7:0]requs;
	 wire requs1;

	 ////
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
	
	 input [7:0]ad_in1;
	 input [7:0]ad_in2;
	 
	 output ad_clk1;
	 output ad_clk2;
	
	 input Clk;
    input reset_n;
   
    output led;
	  
	 wire gmii_tx_clk;
	 wire [7:0]gmii_txd;
	 wire gmii_txen;
	 wire       gmii_rxc;
	 wire [7:0] gmii_rxd;
	 wire       gmii_rxdv;
  
    //eth_rx
    wire [7:0]payload_dat_o;
    wire payload_valid_o;
    wire one_pkt_done;
    //pll
    wire clk50m;
    wire clk125m;
    wire udp_gmii_rst_n;
    wire pll_locked;
    //rxfifo    
    wire [7:0]rxdout;
    wire clk125m_o;
    wire rx_empty;
    wire fifo_rd_req;
    //rxcmd
    wire cmdvalid_0;
    wire [7:0]address_0;
    wire [31:0]cmd_data_0; 
  
    wire [1:0]ChannelSel;
    wire [31:0]DataNum;
    wire [31:0]ADC_Speed_Set;   
    wire RestartReq;
	 wire sample_en;
    
    wire [7:0]adc_data_flag;
    wire [15:0]adc_data_mult_ch;

    //txFIFO
    wire wr_en;
    wire [15:0]din;
    wire txempty;
    wire [7:0]dout;
    wire [14:0]rd_data_count;
    wire wr_data_count;
    wire [15:0]fifowrdata_in;
    //txsend
    wire tx_en_pulse; 
    wire tx_done;
    wire test_en;           
    wire [15:0]lenth_val;
    
    //复位
    assign led = reset_n;

	 wire [7:0]fifo_wrdata;
	 wire fifo_wrreq;
	 
	 wire clk125M_o;
	 wire [15:0]rx_data_length;
	 wire phy_init;	//phy initial done

    wire reset_n;
	 
	 assign ad_clk1 = Clk;
	 assign ad_clk2 = Clk;
	 assign requs = (requs1)?7'd0:7'd200;
	 
	 
	 

	phy_config phy_config_inst(
	 	.clk(Clk),
	 	.rst_n(reset_n),
	 	.phy_rst_n(eth_rst_n),
	 	.mdc(eth_mdc),
	 	.mdio(eth_mdio),
	 	.phy_init(phy_init)
	 );
	 rx_pll rx_pll(
	 	.inclk0(eth_rxc),
	 	.c0(gmii_rxc)
	 );
	 
	 
	 rgmii_to_gmii u_rgmii_to_gmii(
	 	.rgmii_rxc(gmii_rxc),
	 	.rgmii_rxd(eth_rxd),
	 	.rgmii_rxdv(eth_rxdv),
	 	.gmii_rxc(),
	 	.gmii_rxd(gmii_rxd),
	 	.gmii_rxdv(gmii_rxdv)
	 );
	 gmii_to_rgmii u_gmii_to_rgmii(
	 	.gmii_gtxc(gmii_tx_clk),
	 	.gmii_txd(gmii_txd),
	 	.gmii_txen(gmii_txen),
	 	.rgmii_gtxc(eth_gtxc),
	 	.rgmii_txd(eth_txd),
	 	.rgmii_txen(eth_txen)
	 );


    parameter local_mac = 48'h00_0a_35_01_fe_c0;
    parameter local_ip = 32'hc0_a8_01_06;
    parameter local_port = 16'd5000;
            
    eth_udp_rx_gmii eth_udp_rx_gmii (
        .reset_n (reset_n),
        
        .gmii_rx_clk(gmii_rxc),  
        .gmii_rxdv(gmii_rxdv),
        .gmii_rxd(gmii_rxd),
        //out clk
        .clk125m_o(clk125m_o),
       
        .local_mac(local_mac),
        .local_ip(local_ip),
        .local_port(local_port),
        
        .exter_mac(),
        .exter_ip(),
        .exter_port(),
        
        .rx_data_length(),
        .data_overflow_i(),
        
        .payload_valid_o(payload_valid_o),
        .payload_dat_o(payload_dat_o),
        
        .one_pkt_done(one_pkt_done),
        .pkt_error(),
        .debug_crc_check()   
    ); 
    

	 wire data;
	 fifo_rx fifo_rx (
		  .data (payload_dat_o),
		  .rdclk (Clk),
		  .rdreq (fifo_rd_req),
		  .wrclk (clk125m_o),
		  .wrreq (payload_valid_o),
		  .wrfull (),
		  .q (rxdout),
		  .rdempty (rx_empty)
		  );

    eth_cmd eth_cmd (
        .clk(Clk),
        .reset_n(reset_n),
        .fifo_rd_req(fifo_rd_req),
        .rx_empty(rx_empty),
        .fifodout(rxdout),
        .cmdvalid(cmdvalid_0),
        .address(address_0),
        .cmd_data(cmd_data_0)
        );
        
	 reg RestartReq_0_d0,RestartReq_0_d1;
	 reg [31:0]Number_d0,Number_d1;
	 
	 always@(posedge gmii_rxc)
	 begin
		Number_d0 <= DataNum;
		Number_d1 <= Number_d0;
		
		RestartReq_0_d0 <= RestartReq;
		RestartReq_0_d1 <= RestartReq_0_d0;
	 end
		  
		  
	cmd_rx cmd_rx_0(
		.clk(Clk),
		.reset_n(reset_n),
		.cmdvalid(cmdvalid_0),
		.cmd_addr(address_0),
		.cmd_data(cmd_data_0),
		
		.ChannelSel(ChannelSel),
		.DataNum(DataNum),
		.ADC_Speed_Set(ADC_Speed_Set),
		.RestartReq(RestartReq)
	);
	
	wire	adc_data_en;
	speed_ctrl speed_ctrl_0(
		.clk(Clk),
		.reset_n(reset_n),
		.ad_sample(RestartReq),
		.div_set(ADC_Speed_Set),
		.number_data(DataNum),
		.sample_en(sample_en),
		.adc_data_en(adc_data_en)
		
	);
			
		wire [15:0]ad_out;
		wire ad_out_valid;
		
	ad9226_12bit_to_16bit ad9226_12bit_to_16bit_0(
		.clk(Clk),
		.reset_n(reset_n),
		.ad_data_en(adc_data_en),
		.ch_sel(ChannelSel),
		.ad_in1(ad_in1),
		.ad_in2(ad_in2),
		.ad_out(ad_out),
		.ad_out_valid(ad_out_valid)
	);

	wire	payload_req_o;
	 fifo_tx fifo_tx_0 (
		  .rdclk (gmii_rxc),
		  .wrclk (Clk),
		  .wrreq (ad_out_valid),
		  .data (ad_out),
		  .rdreq (payload_req_o),
		  .wrfull (),
		  .q (dout),
		  .rdempty (txempty),
		  .wrusedw (wr_data_count),
		  .rdusedw (rd_data_count)
	 );
	 
	 
    //读使能、发送数据个数控制块
    eth_send_ctrl eth_send_ctrl (
        .clk125M (gmii_rxc),
        .udp_gmii_rst_n(reset_n),
        .fifordempty(txempty),
        .eth_tx_done(tx_done),   
        .tx_en_pulse(tx_en_pulse),
        .rd_data_count(rd_data_count),
        .Number_d1(Number_d1),
        .RestartReq_0_d1(RestartReq_0_d1),
        .lenth_val(lenth_val)               
    ); 


    //（新）DDS信号发生器模块
	 DDS DDS(
		.Clk(Clk),
		.Rst_n(reset_n),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata),
		.DDS_Data(DDS_Data),
		.DDS_Flag(DDS_Flag),
		.Uart_Flag(Uart_Flag),
		.EN_11(requs1)
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
		.Rst_n(reset_n),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata),
		.ADC_Flag(Data_Flag),
		.Byte_En(Byte_En),
		.Tx_Done(Tx_Done),
		.Baud_Set(Baud_Set)
	 );
	 
/*-----------例化DAC信号发生器模块-------*/	
	 DA_chip DA_chip(
		.Clk(Clk),
		.DAC_DATA(DDS_Data[11:4]),
		.DIN(DAC_DIN),
		.daCLK(DAC_SCLK)
	 );

/*-----------例化独立按键检测消抖模块-------*/		
	 key_filter key_filter0(
			.Clk(Clk),
			.Rst_n(reset_n),
			.key_in(Key_in[0]),
			.key_flag(Key_Flag[0]),
			.key_state(Key_Value[0])
	 );

	 key_filter key_filter1(
			.Clk(Clk),
			.Rst_n(reset_n),
			.key_in(Key_in[1]),
			.key_flag(Key_Flag[1]),
			.key_state(Key_Value[1])
	 );
	 
    eth_udp_tx_gmii eth_udp_tx_gmii(
        .clk125M(gmii_rxc),
        .reset_n(reset_n),
                 
        .tx_en_pulse(tx_en_pulse),
        .tx_done(tx_done),
                       
        .dst_mac(48'h84_A9_38_E2_C4_FD),
        .src_mac(48'h00_0a_35_01_fe_c0),  
        .dst_ip(32'hc0_a8_01_02),
        .src_ip(32'hc0_a8_01_06),	
        .dst_port(16'd6100),
        .src_port(16'd5000),
                       
        .data_length(lenth_val),
        .payload_req_o (payload_req_o),
        .payload_dat_i (dout),
   
        .gmii_tx_clk   (gmii_tx_clk),	
        .gmii_txen     (gmii_txen),
        .gmii_txd      (gmii_txd)
    );
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