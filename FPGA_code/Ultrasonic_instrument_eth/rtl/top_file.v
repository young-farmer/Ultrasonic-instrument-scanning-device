/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
// Company       : 武汉芯路恒科技有限公司
//                 http://xiaomeige.taobao.com
// Web           : http://www.corecourse.cn
// 
// Create Date   : 2021/07/04 00:00:00
// Module Name   : ACX720_AD7606_ETH
// Description   : AD7606数据采集以太网传输系统
// 
// Dependencies  : 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module top_file(
	 Clk,
	 reset_n,

    eth_rxc,
	 eth_rxd,
	 eth_rxdv,
	
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
	 eth_mdio
	 );
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
endmodule