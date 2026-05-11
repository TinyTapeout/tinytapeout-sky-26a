/*
 * Copyright (c) 2026 Thomas Gilbert
 * SPDX-License-Identifier: Apache-2.0
 *
 * Blackbox stub for the EP-sensor analog design.
 *
 * The chip is fully analog except for 8 digital inputs (ui_in[7:0]) that
 * select the cv-array perturbation cap bits b0..b7.  The two analog pins
 * ua[0] (V1 tank) and ua[1] (V2 tank, buffered) are the RF probe terminals.
 * All digital outputs are tied low; uio is unused and tristated as inputs.
 */

`default_nettype none

module tt_um_thomas_ep_sensor (
    input  wire       VGND,
    input  wire       VDPWR,    // 1.8 V analog supply (and digital)
    input  wire [7:0] ui_in,    // b0..b7 cv-array perturbation switch controls
    output wire [7:0] uo_out,   // unused
    input  wire [7:0] uio_in,   // unused
    output wire [7:0] uio_out,  // unused
    output wire [7:0] uio_oe,   // unused (kept as inputs)
    inout  wire [7:0] ua,       // analog pins; only ua[1:0] are used
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Tie unused outputs low (TT requirement: no floating outputs).
    assign uo_out  = 8'b0;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // List inputs in a wire to avoid lint warnings about unused signals.
    wire _unused = &{ena, clk, rst_n, uio_in, ui_in, ua, VGND, VDPWR, 1'b0};

endmodule
