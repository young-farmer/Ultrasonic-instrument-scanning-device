/*

rgmii_to_gmii u_rgmii_to_gmii(
	.rgmii_rxc	(),
	.rgmii_rxd	(),
	.rgmii_rxdv	(),
	.gmii_rxc	(),
	.gmii_rxd	(),
	.gmii_rxdv  ()
);

*/

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module ddi_x4 (
	datain,
	inclock,
	dataout_h,
	dataout_l);

	input	[3:0]  datain;
	input	  inclock;
	output	[3:0]  dataout_h;
	output	[3:0]  dataout_l;

	wire [3:0] sub_wire0;
	wire [3:0] sub_wire1;
	wire [3:0] dataout_h = sub_wire0[3:0];
	wire [3:0] dataout_l = sub_wire1[3:0];

	altddio_in	ALTDDIO_IN_component (
				.datain (datain),
				.inclock (inclock),
				.dataout_h (sub_wire0),
				.dataout_l (sub_wire1),
				.aclr (1'b0),
				.aset (1'b0),
				.inclocken (1'b1),
				.sclr (1'b0),
				.sset (1'b0));
	defparam
		ALTDDIO_IN_component.invert_input_clocks = "OFF",
		ALTDDIO_IN_component.lpm_hint = "UNUSED",
		ALTDDIO_IN_component.lpm_type = "altddio_in",
		ALTDDIO_IN_component.power_up_high = "OFF",
		ALTDDIO_IN_component.width = 4;

endmodule

module ddi_x1 (
	datain,
	inclock,
	dataout_h,
	dataout_l);

	input	[0:0]  datain;
	input	  inclock;
	output	[0:0]  dataout_h;
	output	[0:0]  dataout_l;

	wire [0:0] sub_wire0;
	wire [0:0] sub_wire1;
	wire [0:0] dataout_h = sub_wire0[0:0];
	wire [0:0] dataout_l = sub_wire1[0:0];

	altddio_in	ALTDDIO_IN_component (
				.datain (datain),
				.inclock (inclock),
				.dataout_h (sub_wire0),
				.dataout_l (sub_wire1),
				.aclr (1'b0),
				.aset (1'b0),
				.inclocken (1'b1),
				.sclr (1'b0),
				.sset (1'b0));
	defparam
		ALTDDIO_IN_component.invert_input_clocks = "OFF",
		ALTDDIO_IN_component.lpm_hint = "UNUSED",
		ALTDDIO_IN_component.lpm_type = "altddio_in",
		ALTDDIO_IN_component.power_up_high = "OFF",
		ALTDDIO_IN_component.width = 1;

endmodule

//module rgmii_to_gmii(
//	input			rgmii_rxc	,
//	input	[3:0] 	rgmii_rxd	,
//	input 			rgmii_rxdv	,
//	output 			gmii_rxc	,
//	output	[7:0] 	gmii_rxd	,
//	output 			gmii_rxdv
//);
//	reg [3:0] rxdh, rxdl;
//	reg rxdv;
//	always @ (posedge rgmii_rxc) begin
//		rxdl = rgmii_rxd;
//		rxdv = rgmii_rxdv;
//	end
//	
//	always @ (negedge rgmii_rxc) begin
//		rxdh = rgmii_rxd;
//	end
//	
//	assign gmii_rxc = rgmii_rxc;
//	assign gmii_rxd = {rxdh, rxdl};
//	assign gmii_rxdv = rxdv;
//
//
//endmodule

module rgmii_to_gmii(
	input			rgmii_rxc	,
	input	[3:0] 	rgmii_rxd	,
	input 			rgmii_rxdv	,
	output 			gmii_rxc	,
	output	[7:0] 	gmii_rxd	,
	output 			gmii_rxdv
);
	ddi_x4 ddi_x4_inst(
		.datain		(rgmii_rxd		),
		.inclock	(rgmii_rxc		),
		.dataout_h	(gmii_rxd[7:4]	),
		.dataout_l	(gmii_rxd[3:0]	)
	);
	
	ddi_x1 ddi_x1_inst(
		.datain		(rgmii_rxdv),
		.inclock	(rgmii_rxc		),
		.dataout_h	(				),
		.dataout_l	(gmii_rxdv		)
	);
	
	assign gmii_rxc = rgmii_rxc;

endmodule
