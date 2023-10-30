module encode(Clk,Rst_n,in_a,in_b,position);

	input Clk;
	input Rst_n;
	input in_a;
	input in_b;	
	output reg  [7:0] position;
	reg [1:0] state; // 编码器状态
	//reg [7:0] position1=8'd0;
	//assign  position = position1;
	

	always @(posedge Clk or negedge Rst_n) begin
		case (state)
			2'b00: begin
				if (in_a && ~in_b)  // 编码器顺时针旋转
					state <= 2'b01;
				else 
					state <= 2'b00;				
			end
			2'b01: begin
				if (in_a && in_b ) begin // 等待编码器下一个位置
					position <= position+1'b1;
					state <= 2'b00;
				end 
				else if (in_a  && ~in_b )  // 编码器逆时针旋转
					state <= 2'b00;
				else if (~in_a  && in_b)  // 编码器逆时针旋转
					state <= 2'b00;
				else if (~in_a  && in_b ) // 编码器逆时针旋转
					state <= 2'b00;
			end
		endcase
	end
	

endmodule