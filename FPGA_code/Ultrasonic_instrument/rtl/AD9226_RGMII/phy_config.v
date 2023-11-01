module phy_config(
	input  clk,        //模块时钟50MHz
	input  rst_n,      //模块复位，低电平有效
	output phy_rst_n,  //phy芯片复位，低电平有效
	output mdc,        //时钟接口
	inout  mdio,       //数据接口
	output phy_init    //初始化完成标志，高电平有效
);
	reg [23:0] reg_data;  //高3位为0+5位寄存器地址+16位寄存器数据
	reg [23:0] mdio_data;
	reg start;
	reg if_read;  //1：表示读，0：表示写
	wire done;    //一次传输完成标志

	mdio_bit_shift u_mdio_bit_shift(
	    .mdc(mdc),
	    .mdio(mdio),
		 .rst_n(phy_rst_n),
		 .if_read(1'b0),
		 .phy_addr(5'b00001),
	    .mdio_data(mdio_data),
	    .start(start),
	    .done(done)
	);
    
	//系统时钟采用50MHz
	parameter SYS_CLOCK = 50_000_000;
	//SCL总线时钟采用30kHz
	parameter SCL_CLOCK = 30_000;
	//产生时钟SCL计数器最大值
	localparam SCL_CNT_M = SYS_CLOCK/SCL_CLOCK/2 - 1;
	
	reg [19:0] div_cnt;
	always@(posedge clk or negedge rst_n)
	if (!rst_n)
		div_cnt <= 'd0;
	else if(div_cnt < SCL_CNT_M)
		div_cnt <= div_cnt + 1'b1;
	else
		div_cnt <= 'd0;

	wire mdc_pulse = div_cnt == SCL_CNT_M;
	
	reg mdc_clk;
	always@(posedge clk or negedge rst_n)
	if (!rst_n)
		mdc_clk <= 1'b0;
	else if(mdc_pulse)
	    mdc_clk <= ~mdc_clk;
    
	assign mdc = mdc_clk;

	wire Go;	//为1,开始配置PHY寄存器
	reg [15:0] cnt;
	always @ (posedge mdc or negedge rst_n)
	begin
		if (!rst_n)
			cnt <= 0;
		else if (cnt < 16'd2000)
			cnt <= cnt + 1'b1;
	end
	
	assign phy_rst_n = (cnt > 'd400);
	assign Go = (cnt > 'd2000 - 1'b1);

	//配置PHY寄存器状态控制
	reg [1:0] state;
	reg [2:0] reg_cnt;
	parameter MAX_CNT = 1;//要配置的寄存器个数
	always @ (posedge mdc)
	begin
		if (!Go) begin
			state <= 0;
			start <= 0;
			reg_cnt <= 0;
		end
		else if (reg_cnt < MAX_CNT) begin
			case (state)
				0:begin  //开始写寄存器
					start <= 1;
					state <= 1;
					mdio_data <= reg_data;
				end
				1:begin //写寄存器完成
					if (done) begin
						start <= 0;
						state <= 0;
						reg_cnt <= reg_cnt + 1'b1;
					end
				end
			endcase
		end
	end

	assign phy_init = (reg_cnt == MAX_CNT);

	//配置phy寄存器
	always @ (reg_cnt)
	begin
		case (reg_cnt)
			0:reg_data <= 24'h001200;		//掉电
//			1:reg_data <= 24'h002100;		//禁止网卡自动协商，强制让网卡工作在百兆模式
			default:reg_data <= 24'h008000;
		endcase
	end
	
    /*
	100M
	//配置phy寄存器
	always @ (reg_cnt)
	begin
		case (reg_cnt)
			0:reg_data <= 24'h001900;		//掉电
			1:reg_data <= 24'h002100;		//禁止网卡自动协商，强制让网卡工作在百兆模式
			default:reg_data <= 24'h002100;
		endcase
	end
	*/

endmodule
