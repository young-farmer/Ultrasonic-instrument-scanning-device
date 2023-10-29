

module uart_scope(
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
	
		//sdram control
	sdram_clk,
	sdram_cke,
	sdram_cs_n,
	sdram_we_n,
	sdram_cas_n,
	sdram_ras_n,
	sdram_dqm,
	sdram_ba,
	sdram_addr,
	sdram_dq,
	
		//usb
	fx2_clear,
   fx2_fdata,
   fx2_flagb,
   fx2_flagc,
   fx2_ifclk,
   fx2_faddr,
   fx2_sloe,
   fx2_slwr,
   fx2_slrd,
   fx2_pkt_end,
   fx2_slcs,
	
	DAC_DIN,
	DAC_SCLK
);
	
//###################################################################################################



	 
//###################################################################################################
	

	input Clk;	/*系统时钟，50M*/
	input Rst_n;	/*全局复位，低电平复位*/
	input Rs232_Rx;	/*串口接收引脚*/
	output Rs232_Tx;	/*串口发送引脚*/
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



	
	//sdram Interface
	output sdram_clk;
	output sdram_cke;
	output sdram_cs_n;
	output sdram_we_n;
	output sdram_cas_n;
	output sdram_ras_n;
	output [1:0]sdram_dqm;
	output [1:0]sdram_ba;
	output [12:0]sdram_addr;
	inout [15:0]sdram_dq;
	
	////usb_ctrl
   inout [15:0]fx2_fdata;
   input fx2_flagb;
   input fx2_flagc;
   input fx2_ifclk;
   
   output [1:0]fx2_faddr;
   output fx2_sloe;
   output fx2_slwr;
   output fx2_slrd;
   output fx2_pkt_end; 
   output fx2_slcs;
	output fx2_clear;

   wire [1:0]fx2_faddr0;//FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
   wire fx2_slrd0;//FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
   wire fx2_slwr0;//FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
   wire fx2_sloe0;//FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
   wire fx2_flagc0;//FX2型USB2.0芯片的端点6满标志
   wire fx2_flagb0; //FX2型USB2.0芯片的端点2空标志
   wire fx2_pkt_end0;//数据包结束标志信号
   wire fx2_slcs0;
   
   wire [15:0]fx2_fdata1;
   wire [1:0]fx2_faddr1;//FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
   wire fx2_slrd1;//FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
   wire fx2_slwr1;//FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
   wire fx2_sloe1;//FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
   wire fx2_flagc1;//FX2型USB2.0芯片的端点6满标志
   wire fx2_flagb1;//FX2型USB2.0芯片的端点2空标志
   wire fx2_pkt_end1;//数据包结束标志信号
   wire fx2_slcs1;
	
	wire inout_switch; 
	wire rw_switch;   
	wire usb_fifo_wrempty;
   //0: read由pc向FPGA下发指令   1:write由FPGA向fx2芯片继而向pc上传数据
	assign rw_switch = (inout_switch || (usb_fifo_wrempty == 0 ))?1'd1:1'd0;
   //inout_switch为1是rw_switch为1的充分条件，
   //如果usb_fifo_wrempty没有为1，
   //说明usbfifo还没有读完，需要再给它一点读完的时间直到收到它为0的反馈
   assign fx2_fdata=rw_switch? fx2_fdata1 : 16'dz;
   
   assign fx2_faddr=rw_switch ? fx2_faddr1 : fx2_faddr0;
   assign fx2_sloe=rw_switch ? fx2_sloe1 : fx2_sloe0;
   assign fx2_slwr=rw_switch ? fx2_slwr1 : fx2_slwr0;
   assign fx2_slrd=rw_switch ? fx2_slrd1 : fx2_slrd0;
   assign fx2_pkt_end=rw_switch ? fx2_pkt_end1 : fx2_pkt_end0;
   assign fx2_slcs=rw_switch ? fx2_slcs1 : fx2_slcs0;
	
   //锁相环时钟输出，给外部需要50M时钟工作的模块提供时钟， 
	wire clk50m; 
	wire clk_sdr_ctrl;
	wire pll_locked;
	
	wire sdram_init_done;
	
	wire [15:0]usb_data_out;
   wire usb_data_valid;
   wire usb_source_ready;
	
	wire [7:0]cmd_addr;
   wire [31:0]cmd_data;
   wire cmdvalid;
	 
	wire [1:0]adc_ch_sel;
	wire start_sample;
   wire [31:0]set_sample_num;
	wire[31:0]set_sample_speed; 
	
	reg start_sample_r1;
   reg start_sample_r2; 
    
	wire [15:0]usb_fifo_wrdata;
   wire usb_fifo_wrreq;
   wire [10:0]usb_fifo_usedw;
	
	wire rdfifo_clr;
   wire rdfifo_empty;
   wire rdfifo_rden;
   wire [15:0]rdfifo_dout;
	wire wrfifo_clr;
   wire wrfifo_full;
	wire ad_sample_en;
	
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

	
	reg Data_Sel;	/*数据选择信号（选择串口发送DDS_Data 或 ADC_Data）*/
	reg Flag_Sel;	/*数据有效标志信号选择信号（选择DDS_Flag 或ADC_Flag）*/
	
	wire [1:0]Key_Flag;	/*按键检测成功标志信号*/
	wire [1:0]Key_Value;	/*按键检测结果*/
	

	//led[0] 锁相环锁定信号输出，为高，说明锁相环工作正常，时钟正常
	//led[1] sdram初始化完成标识信号，为高，说明sdram已经正常完成初始化
	assign led = {~sdram_init_done,~pll_locked};
	
	//pll锁相环
	pll pll(
		.inclk0(clk),
		.c0(clk_sdr_ctrl),
		.c1(sdram_clk),
		.c2(clk50m),
		.locked(pll_locked)
	);
	

	
	//USB数据流发送控制模块：不断的将端点2中的数据读取出来，数据读取后直接作为端口输出
   usb_stream_out usb_stream_out(
       .clk (clk50m),
       .fx2_fdata (fx2_fdata), //  FX2型USB2.0芯片的SlaveFIFO的数据线
       .fx2_faddr (fx2_faddr0), //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
       .fx2_slrd (fx2_slrd0),  //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
       .fx2_slwr (fx2_slwr0),  //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
       .fx2_sloe (fx2_sloe0),  //  FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
       .fx2_flagc (fx2_flagc ), //  FX2型USB2.0芯片的端点6满标志
       .fx2_flagb (fx2_flagb ), //  FX2型USB2.0芯片的端点2空标志
       .fx2_ifclk (fx2_ifclk ), //  FX2型USB2.0芯片的接口时钟信号
       .fx2_pkt_end (fx2_pkt_end0),	//数据包结束标志信号
       .fx2_slcs (fx2_slcs0),
       .reset_n (Rst_n),
       
       .data_out (usb_data_out),	
       //经过FPGA接收了的USB数据.这个数据从pc经过fx2芯片提供给FPGA
       
       .data_valid (usb_data_valid),	
       //经过FPGA接收了的USB数据有效标志信号.FPGA只要在读数据，这个信号一直拉高输出给FX2
       
       .source_ready (~rw_switch)	
       //外部数据消费者数据接收允许信号，例如FPGA中的缓存FIFO中有足够的空间存储一帧USB数据，则允许从Slave FIFO中去读取数据。当FPGA有能力读取一帧数据，则向外
   );
	
	
	 ////////////下方模块对接收的信号进行解析，输出地址、数据、有效，然后通过地址判断这个数据是采样起始信号，采样数量，还是采样通道////////////
    usb_cmd usb_cmd_inst(
        .Clk (fx2_ifclk),
        .Reset_n (Rst_n),
        .rx_data (usb_data_out),
        .rx_done (usb_data_valid),
        .address (cmd_addr),
        .data (cmd_data),
        .cmdvalid (cmdvalid)
    );
	
	 usb_cmd_rx usb_cmd_rx(
        .clk (fx2_ifclk),
        .reset (~Rst_n),
        .adc_ch_sel (adc_ch_sel),
        .set_sample_num (set_sample_num),
        .set_sample_speed(set_sample_speed),   
        .start_sample (start_sample),
        .cmdvalid (cmdvalid),
        .cmd_addr (cmd_addr),
        .cmd_data (cmd_data)
    );
	 
	 always@(posedge clk50m)
    begin
        start_sample_r1<=start_sample;
        start_sample_r2<=start_sample_r1;
    end
	 
	wire adc_data_en;
   speed_ctrl speed_ctrl(
       .clk(clk50m),
       .reset_n(Rst_n),
       .ad_sample_en(ad_sample_en),
       .adc_data_en(adc_data_en),
       .div_set(set_sample_speed)
   ); 
  
	 
	 //双通道的数据输出模块：AD1030采样的数据是10位的
   ad_10bit_to_16bit ad_10bit_to_16bit
   (
       .clk   (clk50m ),
       .ad_sample_en(ad_sample_en),
       .ch_sel(adc_ch_sel ),
       .ad_in1(ADC_DOUT     ),

       .ad_out(ad_out     ),
       .ad_out_valid(ad_out_valid)    
   );

  state_ctrl state_ctrl(
    .clk (clk50m),
    .reset (~Rst_n),
    .fx2_clear (fx2_clear),
    .inout_switch (inout_switch),

    .sdram_init_done (sdram_init_done),

    .start_sample (start_sample_r2),
    .set_sample_num (set_sample_num),

    .rdfifo_empty (rdfifo_empty),
    .rdfifo_clr (rdfifo_clr),
    .rdfifo_rden (rdfifo_rden),
    .rdfifo_dout (rdfifo_dout),

    .wrfifo_full (wrfifo_full),
    .wrfifo_clr (wrfifo_clr),
    .ad_sample_en (ad_sample_en),
    .adc_data_en    (adc_data_en   ),

    .usb_fifo_wrreq (usb_fifo_wrreq),
    .usb_fifo_wrdata (usb_fifo_wrdata),
    .usb_fifo_usedw (usb_fifo_usedw )
  );
  
	
	sdram_control_top sdram_control_top(
		.Clk(clk_sdr_ctrl),
		.Rst_n(Rst_n),
		.Sd_clk(sdram_clk),
		.Init_done(sdram_init_done),
		
		.Wr_data(ad_out),
		.Wr_en(ad_out_valid && adc_data_en),
		.Wr_addr(0),
		.Wr_max_addr(16*1024*1024-1),
		.Wr_load(wrfifo_clr),
		.Wr_clk(clk50m),
		.Wr_full(wrfifo_full),
		.Wr_use(),
		
		.Rd_data(rdfifo_dout),
		.Rd_en(rdfifo_rden),
		.Rd_addr(0),
		.Rd_max_addr(16*1024*1024-1),
		.Rd_load(rdfifo_clr),
		.Rd_clk(clk50m),
		.Rd_empty(rdfifo_empty),
		.Rd_use(),
		
		.Sa(sdram_addr),
		.Ba(sdram_ba),
		.Cs_n(sdram_cs_n),
		.Cke(sdram_cke),
		.Ras_n(sdram_ras_n),
		.Cas_n(sdram_cas_n),
		.We_n(sdram_we_n),
		.Dq(sdram_dq),
		.Dqm(sdram_dqm)
	);
	
  //USB数据流发送控制模块
  usb_stream_in usb_stream_in(
    .reset_n (sdram_init_done),
    .fx2_fdata (fx2_fdata1), //FX2型USB2.0芯片的SlaveFIFO的数据线
    .fx2_faddr (fx2_faddr1), //FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
    .fx2_slrd (fx2_slrd1), //FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
    .fx2_slwr (fx2_slwr1), //FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
    .fx2_sloe (fx2_sloe1), //FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
    .fx2_flagc (fx2_flagc), //FX2型USB2.0芯片的端点6满标志
    .fx2_flagb (fx2_flagb), //FX2型USB2.0芯片的端点2空标志
    .fx2_ifclk (fx2_ifclk), //FX2型USB2.0芯片的接口时钟信号
    .fx2_pkt_end (fx2_pkt_end1), //数据包结束标志信号
    .fx2_slcs (fx2_slcs1),

    .usb_fifo_wrclk (clk50m),
    .usb_fifo_wrdata(usb_fifo_wrdata),
    .usb_fifo_wrreq (usb_fifo_wrreq),
    .usb_fifo_usedw (usb_fifo_usedw),
    .usb_fifo_wrempty(usb_fifo_wrempty)
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

/*-----------例化ADC采样使能控制模块-------*/	
	Sample_Ctrl Sample_Ctrl(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.m_wr(m_wr),
		.m_addr(m_addr),
		.m_wrdata(m_wrdata),
		.ADC_En(ADC_En)
	);

/*-----------例化ADC转换控制模块-------*/			
	adc128s022 adc128s022(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Data(),	//仅选取ADC采样结果的高8位
		.En_Conv(ADC_En),
		.Conv_Done(ADC_Flag),
		.ad_clk(ADC_SCLK),
		.DOUT(ADC_DOUT),
		.ad_otr(ad_otr)
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
		.Uart_Flag(Uart_Flag)
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
	
/*-----------例化usb传输模块模块-------*/


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
