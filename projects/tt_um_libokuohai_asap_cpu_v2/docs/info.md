<!---
This file is the project datasheet. Keep it in sync with the RTL.
-->

## How it works

ASAP CPU v2 is a SAP-1-style 8-bit computer, in the spirit of Ben Eater's
breadboard CPU. It contains:

- a 4-bit **program counter** (`pc.v`),
- a 4-bit **memory address register** (`mar.v`),
- a 16 x 8 **RAM** (`ram.v`),
- an 8-bit **instruction register** (`ir.v`),
- an **A** and a **B** register (`register.v`),
- an 8-bit **adder/subtractor** ALU (`alu.v`),
- an 8-bit **output register** (`out_reg.v`),
- a 3-digit decimal **7-segment display driver** (`display.v`),
- and a hard-wired **control unit** (`controller.v`) driven by a 6-step T-state
  ring counter.

All blocks exchange data over a single 8-bit bus (a priority mux in
`project.v` — no internal tri-states). Every instruction runs in 6 clock
cycles: `T0`–`T1` fetch the instruction (`MAR ← PC`, then `IR ← RAM[MAR]` and
`PC ← PC+1`), `T2`… execute, and any leftover steps are NOPs.

### Instruction set

Each RAM byte is an instruction: opcode in bits `[7:4]`, a 4-bit RAM address in
bits `[3:0]`.

| Opcode | Mnemonic | Operation             |
|:------:|:---------|:----------------------|
| `0x0`  | `LDA n`  | `A ← RAM[n]`          |
| `0x1`  | `ADD n`  | `A ← A + RAM[n]`      |
| `0x2`  | `SUB n`  | `A ← A − RAM[n]`      |
| `0xE`  | `OUT`    | `OUT register ← A`    |
| `0xF`  | `HLT`    | stop the CPU          |

Any other opcode behaves as a NOP. `HLT` latches the CPU into a halted state
until reset; the display keeps refreshing.

### Output / display

The OUT register is shown as a decimal number (0–255) across **three discrete
single-digit 7-segment displays** — three separate parts, not one 3-digit
module. `display.v` converts the value to BCD (double-dabble) and time-
multiplexes the digits over a shared segment bus:

- `uo[6:0]` — segment lines `a`…`g`, wired in parallel to all three displays,
  active high (`uo[0]` = `a` = "SEG 1", …, `uo[6]` = `g` = "SEG 7").
- `uo[7]` — digit select 1 → the **ones** display, active high.
- `uio[0]` — digit select 2 → the **tens** display, active high.
- `uio[1]` — digit select 3 → the **hundreds** display, active high.

Exactly one digit-select line is high at a time and it advances every clock, so
at the rated 1 MHz all three displays look rock-steady. (`uio_oe` is `0x03`:
only `uio[1:0]` are driven as outputs.)

### Programming the RAM

`uio[6]` is the mode pin: **0 = RUN**, **1 = PROGRAM**.

- In **PROGRAM** mode the CPU is frozen after the mode input has passed through
  its synchronizer. The RAM is written from the pins: `uio[5:2]` is the address,
  `ui[7:0]` is the data byte, and the synchronized rising edge of `uio[7]`
  writes `RAM[uio[5:2]] ← ui[7:0]`. Hold address and data stable for at least
  two clock cycles before raising `uio[7]` and until at least one clock after
  lowering it.
- In **RUN** mode synchronized `uio[7]` is a reset (clears the PC and registers;
  RAM keeps its contents). The external `rst_n` pin asynchronously resets the
  CPU/display state in either mode.

## How to test

1. Hold `uio[6] = 1` (PROGRAM mode), pulse `rst_n` low then high.
2. For each program byte: put the address on `uio[5:2]` and the data on
   `ui[7:0]`, wait at least two clock cycles, raise `uio[7]`, wait at least two
   clock cycles, then lower `uio[7]`.
3. Set `uio[6] = 0` (RUN mode), wait at least two clock cycles, and pulse
   `uio[7]` high then low — this resets the PC to 0 and the CPU starts running.
4. Clock the design and watch the result on the 7-segment displays.

Example: program `LDA 14 ; ADD 15 ; OUT ; HLT` at addresses 0–3, with
`RAM[14] = 5` and `RAM[15] = 3`. After ~24 clocks the display reads `008`.
The cocotb testbench in `test/` exercises exactly this kind of sequence
(add, subtract, chained add, and that `HLT` freezes the output).

## External hardware

Three single-digit common-cathode 7-segment displays (three separate parts, not
one 3-digit module). Wire the seven segment lines `uo[6:0]` to the matching
segment pins (`a`…`g`) of all three displays in parallel. Route each display's
common-cathode pin to ground through a low-side NPN transistor whose base is
driven by that display's select line: `uo[7]` for the ones digit, `uio[0]` for
tens, `uio[1]` for hundreds. Segments and selects are active high — if your
displays are common-anode, invert the segment and select lines instead. With no
external hardware you can still watch the multiplexed segment pattern on the
GPIO, or wire plain LEDs. To drive the program-mode inputs you also need eight
data switches (`ui[7:0]`), four address switches (`uio[5:2]`), and the mode /
write-reset switches (`uio[6]`, `uio[7]`).
