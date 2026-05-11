# Tiny Secure Telemetry Engine

Tiny Secure Telemetry Engine is an 8-input, 8-output ASIC-oriented security and integrity co-processor for TinyTapeout. The design provides a compact stateful datapath for telemetry mixing, pseudo-random byte generation, lightweight integrity checking, and key/configuration stirring.

The chip is implemented as `tt_um_chidam_secengine` and uses only the dedicated 8-bit input bus and dedicated 8-bit output bus for the user application. The bidirectional `uio` pins are intentionally unused and are held inactive.

## Application

Small embedded and IoT systems often need a tiny hardware block that can mix incoming telemetry, generate changing challenge/response bytes, and maintain an integrity state without using a full software cryptographic engine. This project demonstrates a compact hardware security primitive suitable for:

- sensor telemetry integrity tagging
- lightweight challenge/response experiments
- pseudo-random stream generation
- stateful packet/session mixing
- educational ASIC security datapath study

This is not intended as a drop-in replacement for standardized cryptography such as AES, SHA, or HMAC. It is a small manufacturable hardware primitive designed for TinyTapeout area and IO limits.

## How It Works

Internally, the design contains:

- a 32-bit nonlinear state register
- a 16-bit rolling key register
- an 8-bit integrity/check register
- an 8-bit counter
- a registered 8-bit output

Each enabled clock cycle mixes the current input byte with the internal state using nibble substitution, bit rotations, XOR diffusion, and a lightweight feedback step. The selected mode controls how the state, key, integrity byte, and output are updated.

## Pinout

| Pin | Direction | Description |
| --- | --- | --- |
| `ui_in[5:0]` | Input | Payload/control bits |
| `ui_in[7:6]` | Input | Mode select |
| `uo_out[7:0]` | Output | Registered result byte |
| `uio_in[7:0]` | Input | Unused |
| `uio_out[7:0]` | Output | Held at `0x00` |
| `uio_oe[7:0]` | Output | Held at `0x00`, bidirectional pins disabled |
| `clk` | Input | System clock |
| `rst_n` | Input | Active-low reset |
| `ena` | Input | Design enable |

## Modes

The two most significant input bits select the operating mode:

| `ui_in[7:6]` | Mode | Behavior |
| --- | --- | --- |
| `00` | Absorb | Mixes the payload into the nonlinear telemetry state and integrity register |
| `01` | Stream | Produces a pseudo-random stream-style output byte and advances the rolling key |
| `10` | Integrity | Updates the lightweight CRC-style feedback state and emits an integrity-derived byte |
| `11` | Stir | Re-seeds/stirs the state, key, counter, and integrity byte using the current input |

The internal input byte used by the datapath is:

```verilog
din = {ui_in[5:0], ui_in[7:6]};
```

This lets both the payload and selected mode influence the state evolution.

## Reset State

On active-low reset, the engine initializes to fixed nonzero constants:

```verilog
state_reg = 32'h6a09_e667;
key_reg   = 16'h243f;
crc_reg   = 8'h5a;
ctr_reg   = 8'h00;
out_reg   = 8'h00;
```

After reset, `uo_out` is `0x00`. When `ena` is high, the state advances on each rising clock edge. When `ena` is low, the sequential registers hold their values.

## Example Use

1. Reset the design by driving `rst_n = 0`.
2. Release reset with `rst_n = 1`.
3. Drive `ena = 1`.
4. Select a mode using `ui_in[7:6]`.
5. Provide a 6-bit payload on `ui_in[5:0]`.
6. Read the registered result from `uo_out[7:0]` after the next rising clock edge.

## Design Notes

The final implementation was tuned to fit TinyTapeout Sky130 placement and routing. Earlier larger versions intentionally increased utilization but exceeded placement limits. The current design keeps meaningful stateful logic while leaving enough placement/routing margin for the GDS flow to complete.

## Source

Top module:

```verilog
tt_um_chidam_secengine
```

Main RTL file:

```text
src/project.v
```

Testbench files:

```text
test/tb.v
test/test.py
```

## License

Apache-2.0
