
module ad_10bit_to_16bit(
  clk,
  ad_sample_en,
  ch_sel,
  ad_in1,
  ad_in2,
  ad_out,
  ad_out_valid
);

  input clk;
  input ad_sample_en;
  input [1:0]ch_sel;
  input[7:0] ad_in1;
  input[7:0] ad_in2;
  output[15:0] ad_out;
  output ad_out_valid;
  reg[15:0] ad_out;
  reg ad_out_valid;
  
  reg [9:0]adc_test_data;
  always@(posedge clk)
    adc_test_data <= ad_sample_en ? (adc_test_data + 1'b1) : 10'd0;

   wire [7:0]s_ad_in1;
	wire [7:0]s_ad_in2;  
	
	assign s_ad_in1 = ad_in1;
	assign s_ad_in2 = ad_in2;

  always @(posedge clk)
  if(ad_sample_en && ch_sel == 2'b01)
    ad_out<={8'd0,s_ad_in1};//
  else if(ad_sample_en && ch_sel == 2'b00)
    ad_out<={8'd0,s_ad_in2};//
  else if(ad_sample_en && ch_sel == 2'b10)
    ad_out<={4'd0,adc_test_data,2'd0,};
  else
    ad_out <= 16'd0;

  always @(posedge clk)
    ad_out_valid <= ad_sample_en;

endmodule
