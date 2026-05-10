<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Configurable Galois LFSR

## How it works

This project implements a **16-bit Configurable Galois LFSR** (Linear Feedback Shift Register) designed for Tiny Tapeout SKY130.

### Architecture

A **Galois LFSR** (right-shift variant) is used. Each clock cycle in RUN mode:

```
feedback_bit = lfsr_reg[0]
lfsr_next    = {0, lfsr_reg[15:1]} XOR (feedback_bit ? tap_mask : 0)
lfsr_next    = lfsr_next AND width_mask   (zero out inactive upper bits)
```

Compared to a Fibonacci LFSR, the Galois architecture distributes XOR gates across the register rather than concentrating them in a single long chain. This results in a shorter combinational critical path — beneficial for ASIC timing closure on SKY130.

### Configurable Width

Four widths are supported, selected by `ui_in[3:2]` (**captured once at reset release**):

| `ui_in[3:2]` | Width | Max Period | Default Polynomial |
|:---:|:---:|:---:|:---|
| `00` | 4-bit  | 15  | x⁴+x+1 |
| `01` | 8-bit  | 255 | x⁸+x⁶+x⁵+x⁴+1 |
| `10` | 12-bit | 4095 | x¹²+x¹¹+x¹⁰+x⁴+1 |
| `11` | 16-bit | 65535 | x¹⁶+x¹⁵+x¹³+x⁴+1 |

All default polynomials are **verified primitive polynomials** — guaranteed maximal-length sequences.

### Operating Modes

Controlled by `ui_in[1:0]`:

| `ui_in[1:0]` | Mode | Description |
|:---:|:---:|:---|
| `00` | **RUN** | LFSR advances by one step each clock cycle |
| `01` | **LOAD_SEED** | Load a custom 16-bit seed (nibble-serial, 4 cycles) |
| `10` | **LOAD_TAP** | Select a primitive polynomial from the lookup table (1 cycle) |
| `11` | **HOLD** | LFSR output frozen; no state change |

### Loading a Custom Seed (LOAD_SEED)

Loading a 16-bit seed takes **4 consecutive clock cycles** in LOAD_SEED mode, sending one 4-bit nibble per cycle via `ui_in[7:4]`:

| Cycle | `ui_in[7:4]` | Loads |
|:---:|:---:|:---|
| 1 (entry) | `seed[3:0]`  | Bits [3:0] |
| 2         | `seed[7:4]`  | Bits [7:4] |
| 3         | `seed[11:8]` | Bits [11:8] |
| 4         | `seed[15:12]`| Bits [15:12] |

Switch to RUN to apply the seed. The seed is automatically masked to the active width. Loading `0x0000` is safe — hardware promotes it to `0x0001`.

**Example: Load seed `0xA5C3` for 8-bit LFSR (effective seed = `0x00C3`)**

```
Cycle 1: ui_in = 8'b0011_0001  (mode=01, width=01, data=4'h3)
Cycle 2: ui_in = 8'b1100_0001  (mode=01, width=01, data=4'hC)
Cycle 3: ui_in = 8'b0101_0001  (mode=01, width=01, data=4'h5)
Cycle 4: ui_in = 8'b1010_0001  (mode=01, width=01, data=4'hA)
Switch:  ui_in = 8'b0000_0100  (mode=00 = RUN, width=01)
```

### Selecting a Polynomial (LOAD_TAP)

In LOAD_TAP mode, one clock cycle selects a pre-validated primitive polynomial:

| `ui_in[5:4]` (poly_idx) | 4-bit | 8-bit | 12-bit | 16-bit |
|:---:|:---:|:---:|:---:|:---:|
| `00` | x⁴+x+1 | x⁸+x⁶+x⁵+x⁴+1 | x¹²+x¹¹+x¹⁰+x⁴+1 | x¹⁶+x¹⁵+x¹³+x⁴+1 |
| `01` | x⁴+x³+1 | x⁸+x⁴+x³+x²+1 | same as 00 | same as 00 |
| `10` | same as 00 | same as 00 | same as 00 | same as 00 |
| `11` | same as 01 | same as 01 | same as 00 | same as 00 |

All table entries are verified primitive polynomials — guaranteed maximal-length sequences regardless of selection.

### Protection Features

| Feature | Description |
|:---|:---|
| **Lockup protection** | If LFSR state = `0x0000` in RUN mode, next state is forced to `0x0001` |
| **Zero-seed guard** | If loaded seed (masked to active width) is `0x0000`, LFSR starts from `0x0001` |
| **Primitive poly table** | LOAD_TAP only allows pre-validated primitives — non-maximal sequences impossible |
| **Width masking** | Inactive upper bits are permanently forced to `0` |

## How to test

### Quick Start (default 8-bit PRBS)

1. Assert `rst_n = 0`, set `ui_in = 8'h04` (mode=RUN, width=8-bit)
2. Release `rst_n = 1`
3. `{uio_out, uo_out}` now outputs the LFSR sequence each clock cycle
4. `uo_out[0]` is the serial PRBS bit (LSB)

### Full Sequence Verification

1. Reset in 8-bit mode
2. Set `ui_in[1:0] = 00` (RUN)
3. Clock 255 times and record `uo_out`
4. Verify all 255 values from `0x01` to `0xFF` appear exactly once

### Loading a Custom Seed

1. Reset in desired width mode
2. Set `mode = LOAD_SEED` and clock 4 nibbles (LSB-first)
3. Set `mode = RUN` — LFSR starts from custom seed on the next cycle

## External hardware

No external hardware required. Can drive an LED with `uo_out[0]` (serial bit output) or a logic analyser for PRBS verification.
