## How it works

NeuroPulse is a **4-neuron spiking neural network accelerator** using the Leaky Integrate-and-Fire (LIF) model.
Weights are held off-chip by an RP2040, streamed in every pass via PIO — keeping the transistor budget under 2000T.

**Architecture:**
- The FSM processes one neuron at a time, 7 states each → 28 cycles per full network pass
- At 50 MHz this gives ~1.78M passes/second — far beyond the ~100 Hz needed for biological-speed simulation
- Per-neuron state: 6-bit membrane potential (`vmem`) and 3-bit activity trace
- Leak: `vmem = vmem - (vmem >> 2)` — 75% retention per cycle, no multiplier needed

**FSM sequence (per neuron):**

| State    | Action |
|----------|--------|
| LATCH    | Capture `ui_in[7:4]` as external spike injection (neuron 0 only) |
| TRACE    | Decay or reset this neuron's activity trace |
| ACCUM_0–3 | Read `weight[N][i]` from RP2040 on `ui_in[3:0]`, accumulate `spike[i] * weight` |
| THRESH   | Apply threshold, emit spike, reset `vmem` if fired |

**Hebbian learning (LTP only):** when a neuron fires with `learn_ena=1`, `ltp_pulse` goes high on `uo_out[7]`.
The RP2040 watches this signal and increments the corresponding weight in its own table.

## How to test

Connect an RP2040 running the PIO weight-streaming firmware (see `docs/rp2040.md`).

**Minimal smoke test without RP2040:**

1. Hold `rst_n` low, then release. All `vmem` and `spikes` clear to zero.
2. Set `ui_in[7:4]` to inject external spikes (e.g. `0001` = fire neuron 0).
3. `uo_out[3:0]` shows spike outputs; watch `uo_out[4:5]` to see the FSM stepping through neurons 0–3.
4. `uio_out[6:5]` shows the active synapse during ACCUM states; `uo_out[6]` (`in_accum`) gates when the RP2040 must present weights.

**With RP2040:**

1. Pre-load `WEIGHTS[4][4]` table on the RP2040.
2. RP2040 PIO streams `weight[N][syn]` on `ui_in[3:0]`, timed to the chip's deterministic FSM.
3. Monitor `uo_out[7]` (`ltp_pulse`) + `uo_out[5:4]` (`neuron_sel`) for Hebbian weight updates.

## External hardware

- **RP2040** (e.g. Raspberry Pi Pico): holds the 4×4 weight table, streams weights via PIO, applies LTP updates.
  See `docs/rp2040.md` for the full interface protocol and PIO program.
