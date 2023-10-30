// 地址和数据位宽
//`define  ASIZE           12      //SDRAM地址位宽---128Mb SDR SDRAM
`define  ASIZE           13      //SDRAM地址位宽---256Mb SDR SDRAM
`define  DSIZE           16      //SDRAM数据位宽
`define  BSIZE           2       //SDRAM的bank地址位宽
//SDRAM控制器时钟频率
//`define CLK_FRQ 133

/////////////////////////////////////////////////////////////
//操作命令{CS_N,RAS_N,CAS_N,WE}
parameter   C_NOP  = 4'b0111,   //空操作命令
            C_PRE  = 4'b0010,   //预充电命令
            C_AREF = 4'b0001,   //自动刷新命令
            C_MSET = 4'b0000,   //加载模式寄存器命令
            C_ACT  = 4'b0011,   //激活命令
            C_RD   = 4'b0101,   //读命令
            C_WR   = 4'b0100,   //写命令
            C_B_TER= 4'b0110;   //突发终止

/*
////////////  133 MHz  ///////////////
parameter  INIT_PRE   =  26600;               //初始化等待时间>100us,取200us
parameter  REF_PRE    =  3;                   //tRP  >=18ns,取23ns
parameter  REF_REF    =  10;                  //tRFC  >=60ns，取75ns
parameter  AUTO_REF   =  8500000/(2**`ASIZE); //自动刷新周期<64ms/时钟周期/(2^RASIZE) ns
parameter  LMR_ACT    =  2;                   //装载模式寄存器到可激活延时（2个时钟周期）
parameter  PRE_ACT    =  3;                   //precharge 到可激活需要延时最小20ns
parameter  WR_PRE     =  2;                   //WRITE recovery time 1CLK+6ns
parameter  SC_RCD     =  3;                   //激活到读命令或写命令延时tRCD>18ns
parameter  SC_CL      =  2;                   //列选通潜伏期
parameter  SC_BL      =  8;                   //突发长度设置，1,2,4,8可选(2^N,其他值均认为页模式)
///////////////////////////////////////
*/
////////////  100 MHz  ///////////////
parameter  INIT_PRE   =  20000;               //初始化等待时间>100us,取200us
parameter  REF_PRE    =  3;                   //tRP  >=18ns,取30ns
parameter  REF_REF    =  10;                  //tRFC  >=66ns，取100ns
parameter  AUTO_REF   =  6400000/(2**`ASIZE); //自动刷新周期<64ms/时钟周期/(2^RASIZE) ns
parameter  LMR_ACT    =  2;                   //装载模式寄存器到可激活延时（2个时钟周期）
parameter  WR_PRE     =  2;                   //写操作写数据完成到预充电时间间隔
parameter  SC_RCD     =  3;                   //激活到读命令或写命令延时tRCD>18ns
parameter  SC_CL      =  2;                   //列选通潜伏期
parameter  SC_BL      =  128;                 //突发长度设置，1,2,4,8可选(2^N,其他值均认为页模式)
///////////////////////////////////////

//SDRAM模式寄存器参数化表示
parameter  OP_CODE  =  1'b0;                  //写突发模式设置

parameter  SDR_BL = (SC_BL == 1)? 3'b000:     //突发长度设置
                    (SC_BL == 2)? 3'b001:
                    (SC_BL == 4)? 3'b010:
                    (SC_BL == 8)? 3'b011: 3'b111;

parameter  SDR_BT  =  1'b0;                   //突发类型设置

parameter  SDR_CL = (SC_CL == 2)? 3'b10: 3'b11;//列选通潜伏期设置