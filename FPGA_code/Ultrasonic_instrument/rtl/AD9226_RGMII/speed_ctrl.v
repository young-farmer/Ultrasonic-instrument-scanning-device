module speed_ctrl(
	clk,
	reset_n,
	ad_sample,
	div_set,
	number_data,
	
	sample_en,
	adc_data_en
);

	input clk;
	input reset_n;
	input ad_sample;
	input [31:0]div_set;
	input [31:0]number_data;
	
	//ADC采样结果存储使能信号
	output reg adc_data_en;
	output reg sample_en;
	
	reg [31:0]div_cnt;
	
	reg [31:0]data_cnt;
	reg [3:0]state;
	always@(posedge clk or negedge reset_n)
	if(!reset_n)begin
		state <= 1'b0;
		sample_en <= 1'b0;
		div_cnt <= 1'b0;
		adc_data_en <= 1'b0;
		data_cnt <= 31'b0; 
	end
	else begin
		case(state)
			0:
				if(ad_sample)begin
					sample_en <= 1'b1;
					state <= 1;
				end
				else begin
					sample_en <= 1'b0;
					state <= 1'b0;
				end
				
			1:
                begin
					adc_data_en <= 1;
					state <= 2;
				end

			2:
				if(adc_data_en)begin
					data_cnt <= data_cnt + 1'b1;
					if((data_cnt <= (number_data-1'b1)) && (div_set > 0))begin
						state <= 3;
						adc_data_en <= 1'b0;
					end
					if (data_cnt >= (number_data-1'b1) && number_data>0)begin
						sample_en <= 1'b0;
						adc_data_en <= 1'b0;
						data_cnt <= 32'd0;
						state <= 0;
					end
				end

			3:
				begin
					div_cnt <= div_cnt + 1'b1;
					if(div_cnt == div_set-1)begin 
						div_cnt <= 0;
						adc_data_en <= 1;
						state <= 2;
					end
					else begin
						adc_data_en <= 1'b0;
						state <= 3;
					end
				end
				
			default:state <= 0;
		endcase
	end
endmodule
