# TinyCore8

TinyCore8 is a minimal 8-bit programmable CPU implemented in Verilog for Tiny Tapeout SKY130.

## How it works

TinyCore8 has eight 8-bit registers, a 4-bit program counter, a small program memory, and a simple accumulator-style instruction set.

Programs are loaded serially through the input pins using `load_clk`, `load_data`, and `load_enable`. After loading, asserting `run` starts execution.

The CPU can load immediates, move data, perform simple ALU operations, branch, read a 4-bit external input, and write an 8-bit output port. The output port is connected to `uo_out[7:0]`.

## How to test

A simple smoke-test program is:

```text
LDI R0, 0xA5
OUT R0
HALT