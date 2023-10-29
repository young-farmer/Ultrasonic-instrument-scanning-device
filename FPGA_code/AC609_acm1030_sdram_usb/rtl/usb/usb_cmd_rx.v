`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/23 14:39:01
// Design Name: 
// Module Name: uart_cmd_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//本模块的功能是识别初始值是否设置了通道选择（01,10），如果没有设置通道选择，则采用计数器（00）发送
module usb_cmd_rx(
    clk,
    reset,
    adc_ch_sel,
    set_sample_num,
    set_sample_speed,
    start_sample,
    cmdvalid,
    cmd_addr,
    cmd_data
);
    input clk;
    input reset;
    input [31:0]cmd_data;
    input cmdvalid;
    input [7:0]cmd_addr;
    output reg [1:0]adc_ch_sel;
    output reg [31:0]set_sample_num;
    output reg start_sample;
    output reg [31:0]set_sample_speed;
        
      always@(posedge clk or posedge reset)
      if(reset)begin
        adc_ch_sel <= 2'b01;
        set_sample_num <= 32'd16384;//采样最大数量设定为4G
        start_sample <= 1'b1;
        set_sample_speed <= 32'd0; //50M采样率 
      end
      else if(cmdvalid)begin
        case(cmd_addr)
            0: start_sample <= 1'b1;
            1: adc_ch_sel <= cmd_data[1:0];
            2: set_sample_num <= cmd_data[31:0];
            3: set_sample_speed <= cmd_data[31:0];            
            4:
              begin
                adc_ch_sel <= cmd_data[1:0];
                set_sample_num <= cmd_data[23:8];
                start_sample <= 1'b1;
              end
          default:;
        endcase
      end
      else
        start_sample <= 1'b1;
endmodule
