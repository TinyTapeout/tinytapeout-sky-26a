---
hidden: true
title: "GrammarTile — byte-PDA coprocessor"
---

## How it works

GrammarTile is a small synthesizable accelerator that implements the inner
per-byte kernel of a byte-level NFA + bounded pushdown automaton.

A host streams candidate byte sequences in over SPI. For each one it can:

1. Load the chip with a starting PDA state (`LOAD_STATE`).
2. Stream the candidate bytes one at a time (`ADVANCE`).
3. Read back a single accept/reject bit (`QUERY_ACCEPT`).
4. (Optionally) checkpoint and restore the active PDA state (`CHECKPOINT`,
   `RESTORE`) so a single starting state can be tested against many candidate
   sequences without reloading.

Internally the chip classifies each input byte into one of 29 character
classes via a small combinational encoder, advances a 64-bit one-hot
bit-parallel Glushkov NFA, pushes or pops a 16-deep × 4-bit context stack as
the edge action requires, and recomputes the accept signal as
`nfa_accept & stack_empty`.

The full block diagram and pin assignments live in
[`architecture.md`](architecture.md). The grammar that V1 bakes into the NFA
transition matrix is documented in [`grammar-v1.md`](grammar-v1.md).

## How to test

The chip exposes two host interfaces:

- **SPI mode** (`mode_sel = 0`, default): standard mode-3 SPI on
  `ui_in[3:0] = {SCK, MOSI, CS_N, mode_sel}`. Command set:

  | Opcode | Name           | Payload (MOSI)                       | Reply (MISO)              |
  |--------|----------------|--------------------------------------|---------------------------|
  | `0x00` | `RESET`        | none                                 | none                      |
  | `0x01` | `LOAD_STATE`   | 17 bytes (8 NFA + 1 sp + 8 stack)    | none                      |
  | `0x02` | `ADVANCE`      | 1 byte input character               | none (status on `uo[1]`)  |
  | `0x03` | `QUERY_ACCEPT` | 1 dummy byte                         | 1 byte: `{6'b0,err,acc}`  |
  | `0x04` | `CHECKPOINT`   | none                                 | none                      |
  | `0x05` | `RESTORE`      | none                                 | none                      |

- **Parallel-byte fast path** (`mode_sel = 1`): drive a byte on `uio[7:0]`
  and pulse `ui_in[4]` (`par_strobe`) for one clock to advance. Intended for
  bench/FPGA-emulation use where you have a dedicated 8-bit harness instead of
  RP2040 SPI.

Status outputs are continuously visible:

- `uo_out[1]` — `accept` (combinational): `nfa_accept & stack_empty`.
- `uo_out[2]` — `ready`: 1 when the engine is idle and can accept the next command.
- `uo_out[3]` — `error`: latched on stack overflow/underflow or invalid-byte.
- `uo_out[7:4]` — bottom 4 bits of the NFA state vector (silicon-bring-up visibility).

A self-checking cocotb test runs in CI on every push (`.github/workflows/test.yaml`)
and exercises a JSON corpus.

## External hardware

- Tiny Tapeout demo board (RP2040 → SPI on `ui_in[3:0]`, `uo_out[0]` MISO).
- Optional: 8-bit DIP switch + button on `uio[7:0]` and `ui_in[4]` for manual
  byte streaming in `mode_sel=1`.
