<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

`tt_um_neutern_0` is a **Spiking Neural Network (SNN) tile** implementing 4 Leaky Integrate-and-Fire (LIF) neurons arranged in a 2×2 grid. The neurons share a single microcode-driven compute worker that processes spike events in round-robin order.

### Neuron Model

Each neuron maintains three 4-bit biological state registers:

| Register | Bits | Role |
|----------|------|------|
| `vm` — membrane potential | 4-bit signed | Accumulates synaptic input; resets after firing |
| `accum` — synaptic accumulator | 4-bit signed | Integrates weighted spikes before committing to vm |
| `θ` — threshold | 4-bit signed | Firing threshold, loaded from microcode initialisation |

When a spike arrives the neuron's microcode program runs: accumulate the weight into `vm`, compare `vm ≥ θ`, and if true emit an output spike and reset `vm` to zero.

### Spike Flit Format

Both input (`ui`) and output (`uo`) carry the same 8-bit **neutern spike flit**:

```
ui[7:4] = weight[3:0]   4-bit signed synaptic weight
ui[3]   = 0             (unused)
ui[2]   = neuron_y[0]   row address  (0 = top row,    1 = bottom row)
ui[1]   = 0             (unused)
ui[0]   = neuron_x[0]   column address (0 = left col, 1 = right col)
```

Neuron addressing inside the 2×2 grid:

| `neuron_y[0]` | `neuron_x[0]` | Neuron index |
|:-------------:|:-------------:|:------------:|
| 0 | 0 | neuron 0 |
| 0 | 1 | neuron 1 |
| 1 | 0 | neuron 2 |
| 1 | 1 | neuron 3 |

### Handshake Signals

| Pin | Direction | Meaning |
|-----|-----------|---------|
| `uio[0]` — `rv_in_ready` | **output** | Tile is ready to accept a new input spike |
| `uio[1]` — `rv_out_valid` | **output** | Output spike on `uo[7:0]` is valid this cycle |

Input is accepted when both the sender asserts the data **and** `rv_in_ready` is high. Output is captured when `rv_out_valid` is high.

---

## How to test

### Required signals

| Signal | Pin | Direction |
|--------|-----|-----------|
| Clock | `clk` | input |
| Reset (active-low) | `rst_n` | input |
| Spike input byte | `ui[7:0]` | input |
| Spike output byte | `uo[7:0]` | output |
| Tile ready to receive | `uio[0]` | output |
| Output spike valid | `uio[1]` | output |

### Step 1 — Reset

Assert `rst_n = 0` for at least 4 clock cycles, then release (`rst_n = 1`). All neuron contexts are cleared and thresholds will be loaded when the microcode initialisation program runs on first dispatch.

### Step 2 — Send a spike to a neuron

1. Poll `uio[0]` (`rv_in_ready`). Wait until it is **high**.
2. Drive `ui[7:0]` with the desired spike flit:

   | Neuron target | `ui[7:4]` weight | `ui[2]` y | `ui[0]` x | Example byte |
   |:-------------:|:----------------:|:---------:|:---------:|:------------:|
   | neuron 0 | `0001` (+1) | 0 | 0 | `0b00010000` = `0x10` |
   | neuron 1 | `0001` (+1) | 0 | 1 | `0b00010001` = `0x11` |
   | neuron 2 | `0001` (+1) | 1 | 0 | `0b00010100` = `0x14` |
   | neuron 3 | `0001` (+1) | 1 | 1 | `0b00010101` = `0x15` |

3. Hold the value for one clock cycle.

### Step 3 — Observe output spikes

- Monitor `uio[1]` (`rv_out_valid`) each cycle.
- When `rv_out_valid` is high, sample `uo[7:0]`. The flit format is identical to the input: `uo[7:4]` = emitted weight, `uo[2]` = source `neuron_y[0]`, `uo[0]` = source `neuron_x[0]`.

### Step 4 — Threshold test (fire a neuron)

Send repeated spikes with weight `+1` to the same neuron until `vm ≥ θ`. The default threshold is `θ = 7`. Sending 7 consecutive weight-1 spikes to neuron 0 should produce one output spike with source address `neuron_x=0, neuron_y=0`:

```
# 7 input flits: weight=+1, neuron_x=0, neuron_y=0
ui = 0x10  (×7 cycles, waiting for rv_in_ready between each)
# Expected: one output flit with uo = 0x10, rv_out_valid = 1
```

After firing, `vm` resets to zero and the neuron is ready to integrate again.

### Step 5 — Multi-neuron test

Target different neurons in interleaved fashion to confirm independent state:

```
# Spike to neuron 0 with weight +3
ui = 0b00110000  (weight=3, y=0, x=0)

# Spike to neuron 3 with weight +7
ui = 0b01110101  (weight=7, y=1, x=1)
# neuron 3 fires immediately (vm=7 ≥ θ=7), output flit expected on uo
```

### Cocotb test reference

The supplied `test/test.py` exercises the above sequence using the TinyTapeout cocotb harness. Run with:

```bash
cd test && make
```

Waveforms are written to `test/tb.fst` and can be viewed with GTKWave using the pre-configured `test/tb.gtkw` layout.



