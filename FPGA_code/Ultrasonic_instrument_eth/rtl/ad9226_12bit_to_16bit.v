/////////////////////////////////////////////////////////////////////////////////
// Company       : 武汉芯路恒科技有限公司
//                 http://xiaomeige.taobao.com
// Web           : http://www.corecourse.cn
// 
// Create Date   : 2019/05/01 00:00:00
// Module Name   : ad9226_12bit_to_16bit
// Description   : 将ADC采集数据进行有符号数位宽扩展
// 
// Dependencies  : 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module ad9226_12bit_to_16bit(
  clk,
  reset_n,
  ad_data_en,
  ch_sel,
  ad_in1,
  ad_in2,
  ad_out,
  ad_out_valid
);

  input clk;
  input reset_n;
  input [1:0]ch_sel;
  input[7:0] ad_in1;
  input[7:0] ad_in2;
  input ad_data_en;
  
  output[15:0] ad_out;
  output ad_out_valid;
  reg[15:0] ad_out;
  reg ad_out_valid;
  
  always@(posedge clk or negedge reset_n) 
  if(!reset_n)
		ad_out_valid <= 1'b0;
  else 
		ad_out_valid = ad_data_en;
  

  //用于仿真或产生测试数据，可在通过添加`define SIM 进行宏定义
  reg [11:0]adc_test_data;
  //测试数据，当ad_data_en为1时，锁相环生成的50M时钟每个周期使adc_test_data加1
  always@(posedge clk)
    adc_test_data <= ad_data_en ? (adc_test_data + 1'b1) : 12'd0;
  always @(posedge clk or negedge reset_n)
  if(!reset_n)
	 ad_out <= 16'd0;
  else if(ad_data_en && ch_sel == 2'b01)
    ad_out<= {ad_in2,ad_in1};//{{4{ad_in1_0[11]}},ad_in1_0};
  else if(ad_data_en && ch_sel == 2'b10)
    ad_out<= {ad_in1,ad_in2};//{{4{ad_in2[11]}},ad_in2};
  else if(ad_data_en && ch_sel == 2'b00)
    ad_out<= {4'd0,adc_test_data};//{{4{adc_test_data[11]}},adc_test_data};
  else
	 ad_out <= ad_out;
	 
endmodule
