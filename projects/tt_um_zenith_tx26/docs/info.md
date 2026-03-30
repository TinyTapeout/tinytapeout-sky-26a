# Zenith TX26 — 16-bit CPU

A 16-bit CPU designed from scratch in Verilog by Doruk Orak, age 16, Istanbul.

## How it works

The Zenith TX26 is a fully custom 16-bit CPU with:
- 8 registers (R0-R7, R0 hardwired to 0)
- 16 instructions (ADD, SUB, AND, OR, XOR, SHL, SHR, SLT, LDI, ADDI, LD, ST, JMP, BEQ, BLT, NOP)
- Harvard architecture (separate instruction and data memory)
- Runs infinite Fibonacci sequence on output pins

## How to test

Connect 8 LEDs to the output pins. The LEDs will display the current Fibonacci number in binary: 1, 1, 2, 3, 5, 8, 13, 21...

## External hardware

8 LEDs connected to the output pins to display Fibonacci numbers in binary (optional).