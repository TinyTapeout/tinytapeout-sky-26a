<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

TinyTensorCore is a hardware accelerator for 3×3 integer matrix multiplication, designed to fit in a 1×2 TinyTapeout tile. The core takes two 3×3 matrices of 5-bit signed operands as input and produces a 3×3 matrix of 12-bit signed results.

The design is composed of four modules:

- **`tt_um_tinytensorcore`** — top-level wrapper that maps the TinyTapeout pin convention (`ui_in`, `uo_out`, `uio_*`) to a 10-bit instruction bus and a 12-bit result output.
- **`tensor_core_controller`** — instruction decoder and burst-load FSM. Sequences three opcodes: `NOP` (0b000), `TENSOR_CORE` (0b001, triggers the matmul), and `BURST` (0b010, streams 9 operand pairs in or 9 results out over consecutive cycles).
- **`tensor_core_register_file`** — holds two 3×3 matrices of 5-bit signed values (matrix A and matrix B). Loaded one operand pair per cycle during a burst.
- **`tensor_core`** — combinational MAC array that computes the full 3×3 × 3×3 matmul in a single cycle.

The instruction format is 10 bits wide:
- `instr[2:0]` — opcode
- `instr[9:5]` — operand A (matrix A element, 5-bit signed) during burst loads
- `instr[4:0]` — operand B (matrix B element, 5-bit signed) during burst loads (its low 3 bits double as the opcode field)

The 8-bit `ui_in` carries `instr[7:0]`, and `uio_in[5:4]` carries `instr[9:8]`. Results stream out as 12-bit values over `uo_out` (low 8 bits) and `uio_out[3:0]` (high 4 bits, including sign).


## How to test

A typical test sequence:

1. Hold `rst_n` low for several cycles, then release.
2. Issue a `BURST` opcode (0b010) for one cycle to start a load burst.
3. For the next 9 cycles, present operand pairs on the instruction bus — matrix A element on `instr[9:5]`, matrix B element on `instr[4:0]`. Hold low 3 bits at `0b000` (NOP) so the FSM doesn't restart.
4. Wait a few idle cycles, then issue `TENSOR_CORE` opcode (0b001) for one cycle to compute the matmul.
5. Issue another `BURST` opcode to stream the 9 result values out over the next 9 cycles. Each result appears as `{uio_out[3:0], uo_out[7:0]}` — a 12-bit signed value.

Comprehensive RTL vs gate-level verification was performed using Cadence Xcelium with a 26-test suite (identity, all-ones, sequential, max values, zero matrix, diagonal, and 20 random matrices). RTL and gate-level outputs were bit-exact identical.


## External hardware

No external hardware required. 
