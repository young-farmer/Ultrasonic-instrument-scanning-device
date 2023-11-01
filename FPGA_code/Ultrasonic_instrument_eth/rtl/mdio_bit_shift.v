module mdio_bit_shift(
    input         mdc,         //时钟接口
    inout         mdio,        //数据接口
    input         rst_n,       //模块复位，低电平有效
    input         if_read,	   //读写方向控制 1:读，0:写
	 input [4:0]   phy_addr,	   //phy地址
    input [23:0]  mdio_data,   //mdio接口要传输的数据
    input         start,       //开始传输标志
    output reg    done         //传输结束标志
);

    reg [5:0] cnt;
    reg mdio_o;
	 reg mdio_oe;

    assign mdio = mdio_oe ? mdio_o : 1'bz;

    always @ (posedge mdc or  negedge rst_n)
    begin
        if (!rst_n)
			cnt <= 6'b111111;
		else if (start == 1'b0)
			cnt <= 'd0;
		else if (cnt < 6'b111111)
			cnt <= cnt + 1'b1;
    end
	
    always @ (negedge mdc or negedge rst_n)
    begin
		if (!rst_n) begin
			mdio_o <= 1'b1;
			mdio_oe <= 1'b1;
			done <= 1'b0;
		end else
			case (cnt)
				0:begin
					mdio_o <= 1'b1;
					mdio_oe <= 1'b1;
					done <= 1'b0;
				  end
				1:mdio_o <= 1'b0;             //ST 01  2bit
				2:mdio_o <= 1'b1;
				3:mdio_o <= if_read;          //OP 01:write,10:read  2bit
				4:mdio_o <= !if_read;
				5:mdio_o <= phy_addr[4];      //PHYAD  5bit
				6:mdio_o <= phy_addr[3];
				7:mdio_o <= phy_addr[2];
				8:mdio_o <= phy_addr[1];
				9:mdio_o <= phy_addr[0];
				10:mdio_o <= mdio_data[20];   //REGAD  5bit
				11:mdio_o <= mdio_data[19];              
				12:mdio_o <= mdio_data[18];    
				13:mdio_o <= mdio_data[17];    
				14:mdio_o <= mdio_data[16];    
				15:begin
						mdio_o <= !if_read;   //TA     2bit
						mdio_oe <= !if_read;
				   end
				16:mdio_o <= 1'b0;
				17:mdio_o <= mdio_data[15];   //DATA   16bit
				18:mdio_o <= mdio_data[14]; 
				19:mdio_o <= mdio_data[13];
				20:mdio_o <= mdio_data[12];
				21:mdio_o <= mdio_data[11];
				22:mdio_o <= mdio_data[10];
				23:mdio_o <= mdio_data[9];		  
				24:mdio_o <= mdio_data[8];
				25:mdio_o <= mdio_data[7];				  
				26:mdio_o <= mdio_data[6];
				27:mdio_o <= mdio_data[5];
				28:mdio_o <= mdio_data[4];
				29:mdio_o <= mdio_data[3];
				30:mdio_o <= mdio_data[2];
				31:mdio_o <= mdio_data[1];
				32:mdio_o <= mdio_data[0];
				33:begin
						mdio_o <= 1'b1;
						mdio_oe <= 1'b0;
						done <= 1'b1;
				   end
			endcase
    end

endmodule
