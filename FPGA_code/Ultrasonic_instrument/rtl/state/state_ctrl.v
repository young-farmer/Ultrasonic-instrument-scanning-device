/////////////////////////////////////////////////////////////////////////////////
// Company       : 武汉芯路恒科技有限公司
//                 http://xiaomeige.taobao.com
// Web           : http://www.corecourse.cn
// 
// Create Date   : 2019/05/01 00:00:00
// Module Name   : state_ctrl
// Description   : ADC采集数据SDRAM缓存USB发送状态控制模块
// 
// Dependencies  : 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:程序关键点：  
/*当进入写fifo清零状态后，首先开始计数，先保证计数完成，再等待wrfifo_full（写端fifo满信号）的信号拉低，
  拉低后，表示可以往fifo里写入数据，此时进入下一个状态。在清空（复位）fifo的时候，
  fifo的full信号会变高，可以认为在复位fifo时是不允许对fifo进行写操作的，即使写也是不可靠的，
  等fifo的复位结束后，full信号会变低，就允许对fifo进行写操作。清写端fifo的控制信号是由
  计数器(在前3个计数值将清除控制信号拉高)产生3个时钟周期的高电平脉冲
  当进入读fifo清零状态后，首先开始计数，先保证计数完成，再等待rdfifo_empty（读端fifo的空信号）信号拉低，
  拉低后，表示fifo里已经有被写入数据，此时进入下一个状态在清空(复位)fifo的时候，
  fifo的empty信号会变高，可以认为在复位fifo时是不允许对fifo进行读操作的，即使读也是不可靠的，
  等fifo的复位结束后，fifo被写入数据后，empty信号会变低，就允许对fifo进行读操作。
  清读端fifo的控制信号是由计数器(在前3个计数值将清除控制信号拉高)产生3个时钟周期的高电平脉冲*/  
// 
/////////////////////////////////////////////////////////////////////////////////

module state_ctrl(
  clk,
  reset,
  
  fx2_clear,

  sdram_init_done,

  start_sample,
  set_sample_num,//32,4G

  rdfifo_empty,
  rdfifo_clr,
  rdfifo_rden,
  rdfifo_dout,
  wrfifo_full,
  //wrfifo_clr向外打三拍输出，保证wrfifo的清零信号的生效节拍数
  adc_data_en,
  wrfifo_clr,
  
  ad_sample_en,

  usb_fifo_wrdata,
  usb_fifo_wrreq,
  usb_fifo_usedw,
  
  inout_switch
);
  input clk;
  input reset;
  
  output reg fx2_clear;

  input sdram_init_done;

  input start_sample;
  input [31:0]set_sample_num;//32,4G

  input rdfifo_empty;
  output reg rdfifo_clr;
  output reg rdfifo_rden;
  input [15:0]rdfifo_dout;

  input wrfifo_full;
  //wrfifo_clr向外打三拍输出，保证wrfifo的清零信号的生效节拍数
  input adc_data_en;
  output reg wrfifo_clr;
  
  output reg ad_sample_en;

  output reg[15:0]usb_fifo_wrdata;
  output reg usb_fifo_wrreq;
  input [10:0]usb_fifo_usedw;
  output  reg inout_switch;
  //*//状态机的状态总位宽为[3:0]也可行
  reg [4:0]state;
  //统计ADC1030向sdram传送的数据，和set_sample_num位深相同
  reg [31:0]adc_sample_cnt;
  //统计向USB发送ADC数据的个数，和set_sample_num位深一致
  reg [31:0]send_data_cnt;
  //将start_sample_rm进行采样，锁定其只在IDLE状态进行工作有效，其余状态均无效
  reg start_sample_rm;
  //下方信号为写fifo清零的状态计数和保持
  reg [4:0]wrfifo_clr_cnt;
  //下方信号为读fifo清零的状态计数和保持
  reg [4:0]rdfifo_clr_cnt;
  reg [15:0]fiforddata_rm;

  localparam IDLE                   = 4'd0;   //空闲状态
  localparam WR_FIFO_CLEAR          = 4'd1;   //写FIFO清除状态
  localparam ADC_SAMPLE             = 4'd2;   //ADC采样数据状态
  localparam RD_FIFO_CLEAR          = 4'd3;   //读FIFO清除状态
  localparam RESET_USB              = 4'd4;   //复位USB状态
  localparam DATA_SEND_START        = 4'd5;   //数据发送状态
  localparam DATA_SEND_WORKING      = 4'd6;   //数据发送完成状态
 
 //清零USB FIFO延时计数器 
  reg [19:0]rst_usb_cnt;

  always@(posedge clk or posedge reset)
  if(reset)begin
    state<=IDLE;
    rdfifo_rden <= 1'b0;
    fx2_clear <= 1'b1;
    rst_usb_cnt <= 0;
    inout_switch<=1'b0;
  end
  else
    case(state)
      IDLE: //0
      begin
        if(start_sample_rm)begin
          state<=WR_FIFO_CLEAR;
          inout_switch<=1'b1;
        end
        else begin
          state<=state;
          inout_switch<=1'b0;
        end
      end

      WR_FIFO_CLEAR: //1
      begin
        if(!wrfifo_full && (wrfifo_clr_cnt==9))
          state<=ADC_SAMPLE;
        else
          state<=WR_FIFO_CLEAR;
      end

      ADC_SAMPLE: //2
      begin
        if((adc_sample_cnt>=set_sample_num-1'b1)&& adc_data_en)
          state<=RD_FIFO_CLEAR;
        else
          state<=state;
      end

      RD_FIFO_CLEAR: //3
      begin
        if(!rdfifo_empty && (rdfifo_clr_cnt==9))begin
          state<=RESET_USB;
          fx2_clear <= 1'b1;
        end
        else
          state<=state;
      end
      
      RESET_USB://4
        begin
            if(rst_usb_cnt >= 20'hffff0)begin
                rst_usb_cnt <= 0;
                state<=DATA_SEND_START;
            end
            else if(rst_usb_cnt >= 20'h7fff0)begin
                rst_usb_cnt <= rst_usb_cnt + 1'd1;
                fx2_clear <= 1'b0;
            end
            else
                rst_usb_cnt <= rst_usb_cnt + 1'd1; 
        end
        

      DATA_SEND_START: //5
      begin
        state <= DATA_SEND_WORKING;
      end

      DATA_SEND_WORKING: //6
      begin
      //*//如果send_data_cnt（USB发送计数）等于给定的值,则跳转进入IDLE状态
      //如果整个数据块发送完成，则大循环收口
        if(send_data_cnt>=set_sample_num-1'b1)begin
          state <= IDLE;
          rdfifo_rden <= 1'b0;
        end
        else if(usb_fifo_usedw < 512) begin
          rdfifo_rden <= 1'b1;
          state <= DATA_SEND_WORKING;
        end
        else begin
        //*//每发送一个16bit数据，如果不满足if条件，则重新回到本状态
          rdfifo_rden <= 1'b0;
          state <= DATA_SEND_WORKING;
        end
      end

      default://默认为空闲状态，usb发送不使能，不读取fifo
      begin
        state <= IDLE;
        rdfifo_rden <= 1'b0;
        inout_switch<=1'b0;
        rst_usb_cnt <= 0;
        fx2_clear <= 1'b0;
      end
    endcase

  always@(posedge clk or posedge reset)
  if(reset) begin
    usb_fifo_wrreq <= 1'b0;
    usb_fifo_wrdata <= 'd0;
  end
  else if(rdfifo_rden) begin
    usb_fifo_wrreq <= 1'b1;
    usb_fifo_wrdata <= rdfifo_dout;
  end
  else begin
    usb_fifo_wrreq <= 1'b0;
    usb_fifo_wrdata <= 'd0;
  end

//对start_sample采样起始位进行寄存，同时限定其只工作在状态IDLE
  always@(posedge clk or posedge reset)begin  
  if(reset)
    start_sample_rm <= 1'b0;
  else if(state==IDLE && sdram_init_done==1'b1)
    start_sample_rm <= start_sample;
  else 
    start_sample_rm <= 1'b0;
  end

//*//清除写FIFO的计数器，并且保证至少10拍的延时
  always@(posedge clk or posedge reset)begin
  if(reset)
    wrfifo_clr_cnt<=0;
  else if(state==WR_FIFO_CLEAR)//如果进入了清fifo状态
  begin 
    if(wrfifo_clr_cnt==9)
      wrfifo_clr_cnt<=4'd9;
    else
      wrfifo_clr_cnt<=wrfifo_clr_cnt+1'b1;
  end
  else
    wrfifo_clr_cnt<=1'b0;
  end

//*//初始化成功后，进行一次清fifo
//*如果进入了WR_FIFO_CLEAR状态，则在wrfifo_clr_cnt为0,1或2时，清写fifo置1，否则wrfifo_clr为0*//
  always@(posedge clk or posedge reset)begin
  if (reset)
    wrfifo_clr<=0;
  else if(sdram_init_done==1'b0)
    wrfifo_clr<=1'b1;
  else if(state==WR_FIFO_CLEAR)
  begin
    if(wrfifo_clr_cnt==0||wrfifo_clr_cnt==1||wrfifo_clr_cnt==2)
      wrfifo_clr<=1'b1;
    else
      wrfifo_clr<=1'b0;
  end
  else 
    wrfifo_clr<=1'b0;
  end

  always@(posedge clk or posedge reset)begin
  if(reset)
    ad_sample_en<=0;
  else if(state==ADC_SAMPLE)
    ad_sample_en<=1;
  else
    ad_sample_en<=0;
  end

//以下//如果adc_sample_cnt在ADC_SAMPLE状态，则每个时钟周期自加1
	always@(posedge clk or posedge reset)  
    if(reset)                                  
		adc_sample_cnt<=32'd0;
    else if(state==ADC_SAMPLE)begin
        if(adc_data_en)
		adc_sample_cnt<=adc_sample_cnt+1'b1;
		else
		adc_sample_cnt<=adc_sample_cnt;
	end
    else
		adc_sample_cnt<=32'd0;
	

//以下//清除读FIFO的计数器，10拍后指挥状态的跳转
  always@(posedge clk or posedge reset)begin
  if(reset)
    rdfifo_clr_cnt<=0;
  else if(state==RD_FIFO_CLEAR)//如果进入了清fifo状态
  begin 
    if(rdfifo_clr_cnt==9)
      rdfifo_clr_cnt<=4'd9;
    else
      rdfifo_clr_cnt<=rdfifo_clr_cnt+1'b1;
  end
  else
    rdfifo_clr_cnt<=1'b0;
  end

  always@(posedge clk or posedge reset)begin
  if (reset)
    rdfifo_clr<=0;
  else if(sdram_init_done==1'b0)
    rdfifo_clr<=1'b1;
  else if(state==RD_FIFO_CLEAR)begin
    if(rdfifo_clr_cnt==0||rdfifo_clr_cnt==1||rdfifo_clr_cnt==2)
      rdfifo_clr<=1'b1;
     else
      rdfifo_clr<=1'b0;
  end
  else 
    rdfifo_clr<=1'b0;
  end

/*每个send_data_cnt在rdfifo_rden为1的状态下加1，
由于rdfifo_rden为高连续持续一拍，
保证了每次读16bit数时send_data_cnt只持续加1*/
  always@(posedge clk or posedge reset)begin
  if(reset)
    send_data_cnt<=32'd0;
  else if(state==IDLE)
    send_data_cnt<=32'd0;
  else if(rdfifo_rden)
    send_data_cnt<=send_data_cnt+1;
  else 
    send_data_cnt<=send_data_cnt;
  end

endmodule