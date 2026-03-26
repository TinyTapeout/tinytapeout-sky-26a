## How it works

This is a constant-time AES S-Box implementing both SubBytes (encrypt) and
InvSubBytes (decrypt) operations per FIPS 197. The input byte is looked up in
the standard AES substitution table via purely combinational logic (the
synthesis tool optimizes the 256-entry case statement into a LUT network).
Output is registered with one clock cycle latency.

The design is inherently constant-time in hardware: every input takes the
identical path through the same combinational logic, with no data-dependent
control flow, memory access patterns, or timing variation. The mode select
mux operates on the control signal (`uio_in[1]`), never on secret data.

This is part of the [rtlforge](https://github.com/MavenRain/rtlforge) project,
which generates formally-verified cryptographic IP from Rust specifications.

Design reference: FIPS 197, "Advanced Encryption Standard (AES)", NIST, 2001.

## How to test

Set `ui_in[7:0]` to the input byte, `uio_in[0]` = 1 (valid), `uio_in[1]` = 0
for encrypt (SubBytes) or 1 for decrypt (InvSubBytes). After one clock cycle,
read `uo_out[7:0]` for the result. `uio_out[0]` indicates output valid.

To exhaustively verify: iterate all 256 input values and compare against the
FIPS 197 S-Box tables (Figure 7 for encrypt, Figure 14 for decrypt). The
cocotb testbench does this automatically for both modes plus a round-trip
check (InvSubBytes(SubBytes(x)) == x for all x).

## External hardware

None required. The design uses only the dedicated I/O pins on the TinyTapeout
carrier board.
