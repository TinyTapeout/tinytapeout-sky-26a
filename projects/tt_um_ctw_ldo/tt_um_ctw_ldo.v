`default_nettype none

module tt_um_ctw_ldo (
    inout wire VDPWR,   // Chân nguồn 1.8V (Đảm bảo tên này khớp 100% với tên trong file LEF)
    inout wire VGND,    // Chân Mass (Đảm bảo tên này khớp 100% với tên trong file LEF)
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    inout  wire [7:0] ua,       // Analog pins
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Kéo các chân Digital xuống 0 để tránh lỗi Floating
    assign uo_out  = 8'b00000000;
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule
