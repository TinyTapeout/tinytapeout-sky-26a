## How it works

**Nibble** is a minimalistic 4-bit accumulator CPU with a Harvard architecture, designed to fit in a single tile on the TinyTapeout Sky130 process. It executes a simple 16-instruction ISA over a 2-cycle fetch-execute pipeline.

### Architecture Overview

The CPU consists of:
- **4-bit Accumulator (A)**: The primary register for all arithmetic and logic operations
- **4-bit Program Counter (PC)**: Addresses up to 16 external instructions
- **Condition Flags**: Carry (C) and Zero (Z) flags updated by ALU operations
- **Status Registers**: Halted flag and phase indicator (0=FETCH, 1=EXECUTE)
- **External Program Memory**: Up to 16 instructions provided via the input pins (Harvard architecture)

### Instruction Set Architecture

The CPU decodes 8-bit instructions with a 4-bit opcode [7:4] and 4-bit immediate/address [3:0]:

| Opcode | Instruction | Operation | C | Z |
|--------|-------------|-----------|---|---|
| 0x0 | NOP | No operation | - | - |
| 0x1 | LDI imm | A ← imm | - | ✓ |
| 0x2 | ADD imm | A ← A + imm | ✓ | ✓ |
| 0x3 | SUB imm | A ← A − imm | ✓ | ✓ |
| 0x4 | AND imm | A ← A & imm | - | ✓ |
| 0x5 | OR imm | A ← A \| imm | - | ✓ |
| 0x6 | XOR imm | A ← A ^ imm | - | ✓ |
| 0x7 | NOT | A ← ~A | - | ✓ |
| 0x8 | SHL | {C,A} ← {A[3],A<<1} | ✓ | ✓ |
| 0x9 | SHR | {A,C} ← {A>>1,A[0]} | ✓ | ✓ |
| 0xA | JMP addr | PC ← addr | - | - |
| 0xB | JZ addr | if Z: PC ← addr | - | - |
| 0xC | JC addr | if C: PC ← addr | - | - |
| 0xD | JNZ addr | if ¬Z: PC ← addr | - | - |
| 0xE | IN | A ← port_in | - | ✓ |
| 0xF | HLT | Halt execution | - | - |

Legend: ✓ = flag updated, - = flag unchanged

### Pipeline Execution

The CPU operates in a 2-cycle fetch-execute pipeline:

1. **FETCH Phase**: The current PC value is output on `uio[3:0]`. External memory (RP2040 or EEPROM) responds with the instruction on `ui_in[7:0]`, which is latched into the Instruction Register (IR).

2. **EXECUTE Phase**: The latched instruction is decoded and executed. The ALU computes results, flags are updated, and the PC is incremented (or modified by branch operations).

Each instruction takes exactly 2 clock cycles. The phase output (`uo[7]`) toggles between 0 (FETCH) and 1 (EXECUTE) so that the external memory controller can respond synchronously.

### Pin Configuration

**Inputs (ui[7:0])**:
- `ui[3:0]` - Instruction bits 0–3
- `ui[7:4]` - Instruction bits 4–7 (opcode)

**Outputs (uo[7:0])**:
- `uo[3:0]` - Accumulator value (connect to LEDs!)
- `uo[4]` - Carry flag
- `uo[5]` - Zero flag
- `uo[6]` - Halted flag
- `uo[7]` - Phase (0=FETCH, 1=EXECUTE)

**Bidirectional (uio[7:0])**:
- `uio[3:0]` - Program Counter output (address bus for external ROM)
- `uio[7:4]` - General-purpose input port (for IN instruction)

## How to test

### Basic Setup

1. Connect the design to a clock source. The design is rated for 1 MHz operation.
2. Provide an RP2040 microcontroller or external ROM as the program memory:
   - Monitor `uio[3:0]` (PC output) to determine which instruction address is being requested.
   - When `uo[7]` (phase) is 0 (FETCH), drive the corresponding instruction onto `ui[7:0]` within one clock cycle.
3. Connect LEDs to `uo[3:0]` to visualize the accumulator value. Optionally monitor `uo[4:7]` for flags and status.

### Example Program: Count to 15

Load the following 16 instructions into external memory:

```
0x0 (PC=0):  0x10  LDI 0      // A ← 0
0x1 (PC=1):  0x21  ADD 1      // A ← A + 1
0x2 (PC=2):  0x5F  OR 15      // A ← A | 0xF (ensure A ≤ 15)
0x3 (PC=3):  0xB0  JZ 0       // if Z: jump to 0 (never from OR)
...
0xF (PC=15): 0xF0  HLT        // Halt
```

After reset, the accumulator will increment from 0 to 15 on each execution, with LEDs reflecting the count.

### Testing with TinyTapeout Demo Board

The TinyTapeout Sky130 demo board integrates an RP2040 that can act as the program memory controller:

- The RP2040 samples `uio[3:0]` using GPIO pins to determine the current PC.
- It drives the instruction corresponding to that PC onto `ui[7:0]`.
- Each cycle, `uo[7]` (phase) toggles, allowing the RP2040 to synchronize instruction delivery.

Load your program into the RP2040 firmware, and the CPU will execute it automatically with LEDs showing the accumulator state.

## External Hardware

- **Program Memory**: 16×8-bit instruction ROM (can be implemented as:
  - RP2040 microcontroller firmware (recommended for TinyTapeout)
  - External EEPROM or SRAM with address decoder
  - Combinational ROM in additional Verilog/FPGA logic)

- **Clock Source**: Any clock generator capable of 1 MHz (can vary up to a few MHz with timing analysis)

- **LEDs** (optional): 4 LEDs connected to `uo[3:0]` to visualize the accumulator. Additional LEDs can monitor `uo[4:6]` for carry, zero, and halted flags.

- **Input Port** (optional): 4-bit input or button circuit connected to `uio[7:4]` for the `IN` instruction.
