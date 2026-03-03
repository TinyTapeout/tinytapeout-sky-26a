<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a simple posit processing unit, it can add, multiplay, or divide two 8-bit posits each having 2 exponent bits.
Simple ready/valid interfaces hooked up to the main FSM are used to control flow of data between the user and the PPU.
Input and output data registers are read/written to via the uio_in and uio_out bidirectional ports.
These ports are controlled via the ready/valid signals on the ui_in and uo_out ports.

The adder, multiplier, and divider are from this repo: <https://github.com/manish-kj/PACoGen>
Which was a part of this paper: <https://ieeexplore.ieee.org/document/8731915>
## Operation

### To load operand 1:
- wait until uo_out[3] is high, indicating the unit is ready for inputs.
- set uio_in to the desired value, and set ui_in[0] high.

### To load operand 2 AND opcode:
- set uio_in to desired value, and ui_in[4:3] to one of the opcodes shown below.
- set ui_in[1] to high to indicate the operand is valid, and ui_in[2] high to indicate opcode valid, computation doesn't start until both are valid.

### To read output:
- wait until uo_out[0] is high, indicating output is valid.
- read value from uio_out, read uo_out[1] for the zero flag, and read uo_out[2] for the inf flag.
- set ui_in[5] to high when done reading, to indicate that the value has been consumed and the unit will return to initial state

### OPCODES:
- ADD  = 01
- MULT = 10
- DIV  = 11

## How to test

Running make -B in the test directory will run the testbench.
The testbench checks narrow validity of a simple add and simple multiplication, and the ready/valid states (using known perfectly representable decimals like 0.3125 and 1.5).
It also checks the rounding error against the softposit python library and dumps erroneous calculations to the terminal.

Rounding errors are normal!

## External hardware

None
