/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_maxluppe_ttsky26a_analog (
    input  wire       VGND,
    input  wire       VDPWR,    // 1.8v power supply
//    input  wire       VAPWR,    // 3.3v power supply
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    inout  wire [7:0] ua,       // Analog pins, only ua[5:0] can be used
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.
    assign uio_out [7:1] = 0;
    assign uio_oe [7:1] = 0;
	assign uio_oe [0] = 1;
    
    // List all unused inputs to prevent warnings
    wire _unused = &{ena, rst_n, ui_in, 1'b0};

    (* keep_hierarchy = "yes" *) Digital_Analog_Comparator u0 (
        .CLK_COMP(clk),//clk),
        .VinP(ua[0]),
        .VinM(ua[1]),
        .VoutP_NAND(uo_out[0]), .VoutM_NAND(uo_out[1]),
        .VoutP_AO22(uo_out[2]), .VoutM_AO22(uo_out[3]),
        .VoutP_MX21(uo_out[7]), .VoutM_MX21(uo_out[6]),
        .VoutP_OAI211(uo_out[4]), .VoutM_OAI211(uo_out[5]),
		.Vout_DIGOTA(uio_out[0])
  );

endmodule
