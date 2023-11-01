/*

gmii_to_rgmii u_gmii_to_rgmii(
	.gmii_gtxc  (),
	.gmii_txd   (),
	.gmii_txen  (),
	.rgmii_gtxc (),
	.rgmii_txd  (),
	.rgmii_txen ()
);

*/

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module ddo_x4 (
	datain_h,
	datain_l,
	outclock,
	dataout);

	input	[3:0]  datain_h;
	input	[3:0]  datain_l;
	input	  outclock;
	output	[3:0]  dataout;

	wire [3:0] sub_wire0;
	wire [3:0] dataout = sub_wire0[3:0];

	altddio_out	ALTDDIO_OUT_component (
				.datain_h (datain_h),
				.datain_l (datain_l),
				.outclock (outclock),
				.dataout (sub_wire0),
				.aclr (1'b0),
				.aset (1'b0),
				.oe (1'b1),
				.oe_out (),
				.outclocken (1'b1),
				.sclr (1'b0),
				.sset (1'b0));
	defparam
		ALTDDIO_OUT_component.extend_oe_disable = "OFF",
		ALTDDIO_OUT_component.invert_output = "OFF",
		ALTDDIO_OUT_component.lpm_hint = "UNUSED",
		ALTDDIO_OUT_component.lpm_type = "altddio_out",
		ALTDDIO_OUT_component.oe_reg = "UNREGISTERED",
		ALTDDIO_OUT_component.power_up_high = "OFF",
		ALTDDIO_OUT_component.width = 4;

endmodule

module ddo_x1 (
	datain_h,
	datain_l,
	outclock,
	dataout);

	input	[0:0]  datain_h;
	input	[0:0]  datain_l;
	input	  outclock;
	output	[0:0]  dataout;

	wire [0:0] sub_wire0;
	wire [0:0] dataout = sub_wire0[0:0];

	altddio_out	ALTDDIO_OUT_component (
				.datain_h (datain_h),
				.datain_l (datain_l),
				.outclock (outclock),
				.dataout (sub_wire0),
				.aclr (1'b0),
				.aset (1'b0),
				.oe (1'b1),
				.oe_out (),
				.outclocken (1'b1),
				.sclr (1'b0),
				.sset (1'b0));
	defparam
		ALTDDIO_OUT_component.extend_oe_disable = "OFF",
		ALTDDIO_OUT_component.invert_output = "OFF",
		ALTDDIO_OUT_component.lpm_hint = "UNUSED",
		ALTDDIO_OUT_component.lpm_type = "altddio_out",
		ALTDDIO_OUT_component.oe_reg = "UNREGISTERED",
		ALTDDIO_OUT_component.power_up_high = "OFF",
		ALTDDIO_OUT_component.width = 1;

endmodule

module gmii_to_rgmii(
	gmii_gtxc,
	gmii_txd,
	gmii_txen,
	rgmii_gtxc,
	rgmii_txd,
	rgmii_txen
);
	input gmii_gtxc;
	input [7:0] gmii_txd;
	input gmii_txen;
	output rgmii_gtxc;
	output [3:0] rgmii_txd;
	output rgmii_txen;
	
	ddo_x4 ddo_x4_inst(
		.datain_h(gmii_txd[3:0]),
		.datain_l(gmii_txd[7:4]),
		.outclock(gmii_gtxc),
		.dataout(rgmii_txd)
	);
	
	ddo_x1 ddo_x1_inst(
		.datain_h(gmii_txen),
		//.datain_l(gmii_txen),
		.datain_l(gmii_txen ^ 1'b0),
		//.datain_l(1'b0),
		//.datain_l(1'b1),
		.outclock(gmii_gtxc),
		.dataout(rgmii_txen)
	);
	
	ddo_x1 ddo_x1_clk(
		.datain_h(1'b1),
		.datain_l(1'b0),
		.outclock(gmii_gtxc),
		.dataout(rgmii_gtxc)
	);

endmodule
