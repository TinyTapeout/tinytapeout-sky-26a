<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
It is an ALU with AND, OR, XOR and ADD operations. It takes in two 3-bit operands as well as a 2-bit OPCODE and outputs a 3-bit output as well as carry and negative flags.

All operations are done simultaneously for each input. A multiplexer is then used to select which operation to forward to the output.

## How to test

|  OPC    |    Operation  |
|---------|---------------|
|  0  0   |      AND      |
|  0  1   |      OR       |
|  1  0   |      XOR      |
|  1  1   |      ADD      |

|  input 7, 6, 5, 4, 3, 2, 1, 0  |  output 4, 3, 2, 1, 0  |
|--------------------------------|------------------------|
|          B[7:5] A[4:2] OPC[1:0]|         Z  C    Y[2:0] |
|--------------------------------|------------------------|
|        0  0  0  0  0  0  0  0  |         1  0  0  0  0  |
|        0  0  1  0  1  0  0  1  |         0  0  0  1  1  |
|        0  1  1  0  0  1  1  1  |         0  0  1  0  0  |


## External hardware

I used an 8-input DIP switch to simulate the inputs and LEDs to show the outputs.

