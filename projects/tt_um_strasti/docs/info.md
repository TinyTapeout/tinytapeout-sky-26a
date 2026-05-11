<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works 

8-Bit ALU with state machine to read A and B inputs using the 8 digital pins.
Operation control over the In/Out pins.
Status out over the In/Out pins.

## Overview
This project implements an **8-bit Arithmetic Logic Unit (ALU)** capable of performing operations on two 8-bit inputs (`A` and `B`).  
The design uses a **Finite State Machine (FSM)** to control input reading, calculation, and result/status output.

## Supported Operations
The ALU supports the following 7 operations:

| Operations   |
|--------------|
| A |
| NOT A |
| A AND B |
| A OR B |
| A XOR B |
| A + B |
| A - B |

## Control Logic
Inputs are read sequentially using an FSM with dedicated states for reading operands and producing outputs.

### FSM States

| State  | S0 | S1 |
|-------|----|----|
| READ_A | 0 | 0 |
| READ_B | 0 | 1 |
| CALC   | 1 | 0 |
| STATUS | 1 | 1 |

- **READ_A** – reads the first operand `A`
- **READ_B** – reads the second operand `B`
- **CALC** – performs the selected ALU operation
- **STATUS** – outputs extended status information about the result

## Operation Control
Operations are selected using the **`f[4:0]` control inputs** from bidirectional pins.

| Operation | F0 | F1 | F2 | F3 | F4 |
|-----------|----|----|----|----|----|
| A | 0 | 0 | 0 | 0 | 1 |
| NOT A | 1 | 0 | 0 | 0 | 1 |
| A AND B | 0 | 1 | 0 | 0 | 0 |
| A OR B | 0 | 1 | 0 | 0 | 1 |
| A XOR B | 0 | 1 | 0 | 1 | 0 |
| A + B | 0 | 1 | 0 | 1 | 1 |
| A - B | 0 | 1 | 1 | 0 | 0 |

## ALU Status Flags

| Flag Name        | Binary Value | Description |
|------------------|-------------|-------------|
| DEFAULT_FLAG   | 00 | Default state, no special condition |
| ZERO_FLAG    | 01 | Result of the operation is zero |
| NEGATIVE_FLAG  | 10 | Result is negative |
| OVERFLOW_FLAG  | 11 | Arithmetic overflow occurred |

## Top-Level I/O
| Signal        | Dir | W | Description |
| --- | :---: | :---: | --- |
| `clk`           | in  | 1 | System clock |
| `rst_n`         | in  | 1 | Async reset (active-low) |
| `ena`           | in  | 1 | Always '1' on TinyTapeout |
| `ui_in[7:0]`    | in  | 8 | Inputs for reading A and B operators |
| `uo_out[7:0]`   | out | 8 | Outputs displaying result and status of ALU |
| `uio_in[7:3]`   | in  | 5 | F0-F4 Control Keys |
| `uio_in[2]`     | in  | 1 | Carry/Borrow Input |
| `uio_out[7:0]`  | out | 8 | *Unused* - set to '0' |
| `uio_oe[7:0]`   | out | 8 | set to '0' using uio as inputs |

## How to test

1. Set status READ_A or READ_B to read A and B operators
2. Set the operation using the f[] birectional inputs
3. Set status CALC, ALU peroforms operation and displays result
4. Set status STATUS do display ALU status flag and carry/borrow out
