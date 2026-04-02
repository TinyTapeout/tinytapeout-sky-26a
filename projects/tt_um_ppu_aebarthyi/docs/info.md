<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## What are posits?

Posits are an alternative to IEEE 754 floating point, proposed by John Gustafson. They use a variable-length regime field that gives them tapered precision — more accuracy near 1.0 where you usually need it, less out at the extremes. An 8-bit posit with 2 exponent bits covers a surprisingly usable dynamic range while being dead simple to decode in hardware.

The really interesting bit is the quire — a fixed-point accumulator wide enough to hold exact products without rounding. This means you can do long dot products and the intermediate sum never loses a bit. You only round once at the very end when you convert back to a posit. For 8-bit posits this is practical to build in silicon, which is exactly what this project does.

If you want to read more: <https://posithub.org/docs/Posits4.pdf>

## How it works

This is a posit multiply-accumulate (MAC) unit with a 32-bit quire register. It takes two 8-bit posit inputs (es=2), multiplies them, and accumulates the exact product into the quire. You can then read the quire back out as a posit8, or clear it for the next dot product.

The 32-bit quire uses Q16.16 fixed-point format, covering values from 2^-16 to 2^15. This is a compromise — a full-precision quire for posit(8,2) would need 128 bits, but 32 bits fits on a 1x1 tile while still covering the most practical range of posit8 values.

The multiply path reuses building blocks from PACoGen: <https://github.com/manish-kj/PACoGen>
Which was part of this paper: <https://ieeexplore.ieee.org/document/8731915>

Simple ready/valid interfaces hooked up to the main FSM control data flow between the user and the unit.
Input and output data registers are read/written via the uio_in and uio_out bidirectional ports.
These ports are controlled via the ready/valid signals on ui_in and uo_out.

## Operation

### MAC (multiply-accumulate):
- wait until uo_out[3] is high, indicating the unit is ready for inputs.
- set uio_in to operand 1, and set ui_in[0] high.
- set uio_in to operand 2, set ui_in[4:3] to 01 (MAC opcode).
- set ui_in[1] high to indicate operand valid, and ui_in[2] high for opcode valid. Computation starts when both are valid.
- wait until uo_out[0] is high, indicating output is valid.
- read uio_out for the posit8 result (current quire converted to posit), uo_out[1] for zero, uo_out[2] for inf, uo_out[4] for overflow.
- set ui_in[5] high when done reading, unit returns to initial state.

### READ (read quire as posit8):
- wait until uo_out[3] is high.
- set ui_in[4:3] to 10 (READ opcode) and ui_in[2] high. No operands needed.
- wait for uo_out[0] high, read result from uio_out.
- set ui_in[5] high to acknowledge.

### CLEAR (zero the quire):
- wait until uo_out[3] is high.
- set ui_in[4:3] to 11 (CLEAR opcode) and ui_in[2] high. No operands needed.
- wait for uo_out[0] high.
- set ui_in[5] high to acknowledge.

### Opcodes (ui_in[4:3]):
- MAC   = 01
- READ  = 10
- CLEAR = 11

### Overflow behavior:
When the quire overflows, it clamps to its max representable value (preserving sign), the overflow flag (uo_out[4]) latches high, and posit output returns maxpos or -maxpos. The overflow flag stays latched until a CLEAR is issued.

## How to test

Running `make -B` in the test directory will run the testbench.
The testbench checks basic MAC, READ, and CLEAR operations using known perfectly representable values (like 1.5 and 0.3125), verifies accumulation across multiple MACs, tests negative values and zero handling, and validates the ready/valid FSM states.

It also runs a dot product fuzz test — random-length sequences of MACs with random posit8 values — and compares the result against a float reference using the softposit python library.

Rounding errors at the edges of the quire's Q16.16 range are expected.

## External hardware

None
