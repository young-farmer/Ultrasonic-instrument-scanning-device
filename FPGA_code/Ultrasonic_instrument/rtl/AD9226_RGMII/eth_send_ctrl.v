`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module eth_send_ctrl(
    clk125M,
    udp_gmii_rst_n,
    fifordempty,
    eth_tx_done,
    
    rd_data_count,
    Number_d1,       
    RestartReq_0_d1, 
    lenth_val,
    tx_en_pulse
    ); 
    
    input clk125M;
    input udp_gmii_rst_n;
    input eth_tx_done;
    input fifordempty;
    
    input [14:0]rd_data_count;
    input [15:0]Number_d1;       
    input RestartReq_0_d1; 
    output reg [15:0]lenth_val; 
    output reg tx_en_pulse;

    reg [3:0]state;
    reg [3:0]state_0;
    reg [15:0]lenth_Num;
    reg [28:0]cnt_dly_time;

    parameter cnt_dly_min = 9'd256;
	 
    //采集数据最大字节数：1500-IP报文头部（20字节）-UDP报文头部（8字节）= 1472字节
    always@(posedge clk125M or negedge udp_gmii_rst_n)
    if(!udp_gmii_rst_n)begin
        lenth_val <= 16'd0;
        lenth_Num <= 16'd0;
        state <= 0;
    end
    else begin
        case(state)
            0:
                if(RestartReq_0_d1)begin
                    lenth_val <= Number_d1 + Number_d1;
                    lenth_Num <= Number_d1;
						 if(Number_d1>16'd736)begin
							  lenth_val <= 16'd1472;
							  state <= 1;
						 end
                end

            1:       
                if(lenth_Num>16'd736)begin
                    lenth_val <= 16'd1472;
                    state <= 2;
                end
                else
                    state <= 3;

            2:
                if(eth_tx_done)begin
                    lenth_Num <= lenth_Num - 16'd736;
                    state <= 1;
                end
            3:
                begin
                    lenth_val <= lenth_Num + lenth_Num;
                    if(eth_tx_done)begin
                        lenth_val <= 16'd0; 
                        lenth_Num <= 16'd0;
                        state <= 0;
                    end 
                end      
            default:state <= 0;
        endcase
    end
       
    always@(posedge clk125M or negedge udp_gmii_rst_n)
    if(!udp_gmii_rst_n)begin
       state_0 <= 1'b0;   
       tx_en_pulse <= 1'b0;
       cnt_dly_time <= 28'd0;
    end
    else begin
       case(state_0)
           0:
              if((rd_data_count>=lenth_val) & (lenth_val>0) & (!fifordempty))begin				  
                  state_0 <= 1;
						tx_en_pulse <= 1'b1;
              end
              else begin
						tx_en_pulse <= 1'b0;
                  state_0 <= 0;
				  end
			  1:
			     begin
                  tx_en_pulse <= 1'b0; 
				  if(eth_tx_done)begin
						state_0 <= 2;
				  end
				  else
                  state_0 <= 1;
				  end		 
           2:	
				  if(cnt_dly_time == cnt_dly_min)begin
                  cnt_dly_time <= 28'd0;
						state_0 <= 0;
              end
				  else begin
						cnt_dly_time <= cnt_dly_time + 1'b1;
						state_0 <= 2;
				  end
           default:
               begin
                   state_0 <= 0;
                   tx_en_pulse <= 1'b0;
                   cnt_dly_time <= 28'd0;
               end
       endcase
    end
endmodule

