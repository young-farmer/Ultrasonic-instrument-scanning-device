`timescale 1ns / 1ps
`define CLK_PERIOD 8
//////////////////////////////////////////////////////////////////////////////////
module AD9226_RGMII_TB();
	reg Clk;
	reg reset_n;
	reg eth_rxc;
		
	wire led;
	wire gmii_tx_clk;
	
	reg [7:0]dout;
	wire payload_req;
	reg tx_en_pulse;
	wire tx_done;
	 
	wire	[3:0]eth_rxd;
	wire	eth_rxdv;
	wire	eth_gtxc;
	wire	[3:0]eth_txd;
	wire	eth_txen;
	wire	eth_rst_n;
	wire	eth_mdc;
	wire	eth_mdio;
	
	wire gmii_gtxc;
	wire [7:0] gmii_txd;
	wire gmii_txen;
	wire rgmii_gtxc;
	wire [3:0] rgmii_txd;
	
	wire [11:0]ad_in1;
	wire [11:0]ad_in2;

	assign eth_rxd = rgmii_txd;

	reg cnt_req;
	reg [56:0]ad_cnt;
	always@(posedge Clk or negedge reset_n)
	if(!reset_n)
	ad_cnt <= 16'd0;
	else if(cnt_req == 1'b1)begin
		if(ad_cnt == 56'hfffffff)
			ad_cnt <= 16'd0;
		else 
			ad_cnt <= ad_cnt + 1'b1;
	end
	else
		ad_cnt <= 16'd0;
		
	 
	assign	ad_in1 = ad_cnt;
	assign	ad_in2 = ad_cnt;
	  
	initial begin
	  cnt_req = 1'b0;
	  @(posedge AD9226_RGMII_0.adc_data_en)
	  cnt_req = 1;
	  #100;
	  wait(AD9226_RGMII_0.sample_en == 0);
	  cnt_req = 1'b0;
	  @(posedge AD9226_RGMII_0.adc_data_en)
	  cnt_req = 1;
	  #100;
	  wait(AD9226_RGMII_0.sample_en == 0);  
	  cnt_req = 1'b0;
	end
	
	AD9226_RGMII AD9226_RGMII_0(
	 .Clk(Clk),
	 .reset_n(reset_n),
	
	 .eth_rxc(eth_rxc),
	 .eth_rxd(eth_rxd),
	 .eth_rxdv(eth_rxdv),
	 
	 .led(led),
	 .ad_in1(ad_in1),
	 .ad_in2(ad_in2),
	
	 .eth_gtxc(eth_gtxc),
	 .eth_txd(eth_txd),
	 .eth_txen(eth_txen),
	 .eth_rst_n(eth_rst_n),
	 .eth_mdc(eth_mdc),
	 .eth_mdio(eth_mdio)
	);
    
   eth_udp_tx_gmii eth_udp_tx_gmii
   (
     .clk125M(eth_rxc),
     .reset_n(reset_n),
                    
     .tx_en_pulse(tx_en_pulse),
     .tx_done(tx_done),
                    
     .dst_mac(48'h00_0a_35_01_fe_c0),
     .src_mac(48'h8C_8C_AA_A5_7B_D7),  
     .dst_ip(32'hc0_a8_00_02),
     .src_ip(32'hc0_a8_00_03),	
     .dst_port(16'd5000),
     .src_port(16'd6000),
                    
     .data_length(16'd32),
     
     .payload_req_o (payload_req),
     .payload_dat_i (dout),
   
     .gmii_tx_clk(gmii_tx_clk),	
     .gmii_txen(gmii_txen),
     .gmii_txd(gmii_txd)
   );
    
	assign gmii_gtxc = eth_rxc;
	
	gmii_to_rgmii gmii_to_rgmii_0(
		.gmii_gtxc(gmii_gtxc),
		.gmii_txd(gmii_txd),
		.gmii_txen(gmii_txen),
		.rgmii_gtxc(rgmii_gtxc),
		.rgmii_txd(rgmii_txd),
		.rgmii_txen(eth_rxdv)
	);

    initial Clk = 1;
    always #10 Clk = ~Clk;
    initial eth_rxc = 1;
    always #4 eth_rxc = ~eth_rxc;
    
    initial begin
        reset_n = 0;
        tx_en_pulse = 0;
        #201;
        reset_n = 1;
        #2000;
        tx_en_pulse = 1;
        #8;
        tx_en_pulse = 0;
        #40;
        @(posedge tx_done);
        #80000;
        tx_en_pulse = 1;
        #8;
        tx_en_pulse = 0;
        #40;
        tx_en_pulse = 1;
        #8;
        tx_en_pulse = 0;
        #40;
		  
        @(posedge tx_done);
        #80000;
        tx_en_pulse = 1;
        #8;
        tx_en_pulse = 0;
        #40; 		  
        $stop;		
	end
    
    reg [5:0]data_cnt;
    
	 reg [39:0]CMD0,CMD1,CMD2,CMD3;
//	 reg [39:0]CMD0,CMD1,CMD2;
//	 reg [39:0]CMD0,CMD1;
//	 reg [39:0]CMD0;
	 
    initial begin
	     CMD0 = 40'h03_00_00_00_01;  //设置采集频率
        CMD1 = 40'h02_00_00_01_00;  //采数据
        CMD2 = 40'h01_00_00_00_01;  //设置采集通道
        CMD3 = 40'h00_00_00_00_01;  //启动发送
    end
    
    always@(posedge eth_rxc or negedge reset_n)
    if(!reset_n)
        data_cnt <= 0;
    else begin
        if(payload_req)
            data_cnt <= data_cnt + 1'd1;
        else
            data_cnt <= 0;
    end
        
    
    always@(*)
        case(data_cnt)
            0,8,16,24:dout = 8'h55;
            1,9,17,25:dout = 8'hA5;
            7,15,23,31:dout = 8'hF0;
				
//				0:dout = 8'h55;
//          1:dout = 8'hA5;
//          7:dout = 8'hF0;
            
            2:dout = CMD0[39:32]; //地址
            3:dout = CMD0[31:24];
            4:dout = CMD0[23:16];
            5:dout = CMD0[15:8];
            6:dout = CMD0[7:0];
 
            2+8:dout = CMD1[39:32]; //地址
            3+8:dout = CMD1[31:24];
            4+8:dout = CMD1[23:16];
            5+8:dout = CMD1[15:8];
            6+8:dout = CMD1[7:0];   

            2+16:dout = CMD2[39:32]; //地址
            3+16:dout = CMD2[31:24];
            4+16:dout = CMD2[23:16];
            5+16:dout = CMD2[15:8];
            6+16:dout = CMD2[7:0]; 
				
				2+24:dout = CMD3[39:32]; 
            3+24:dout = CMD3[31:24];
            4+24:dout = CMD3[23:16];
            5+24:dout = CMD3[15:8];
            6+24:dout = CMD3[7:0]; 
          default:dout = 0;
        endcase     

endmodule
