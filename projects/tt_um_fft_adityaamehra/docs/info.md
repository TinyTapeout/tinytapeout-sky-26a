<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This design implements a **64-point Radix-2 Single Delay Feedback (SDF) Decimation-In-Frequency (DIF) FFT** in silicon, targeting the Tiny Tapeout 6×2 tile footprint.

### Architecture

The pipeline consists of 6 cascaded `sdf_stage` modules (since log₂(64) = 6). Each stage contains:

- A **delay line** (shift register) whose depth halves per stage: 32 → 16 → 8 → 4 → 2 → 1.
- A **Radix-2 DIF butterfly** unit that computes the complex sum `A+B` and the twiddle-multiplied difference `(A−B)·W`.
- An **asynchronous twiddle ROM** storing 32 pre-computed phase factors W₆₄⁰⁻³¹ as 8-bit signed real/imaginary coefficients.

Data routing through each stage is controlled by a single `sel` bit derived from the shared 6-bit `master_cnt` counter in `top.v`.

### Numerical Format

All data paths are **8-bit signed two's complement integers**. To prevent overflow, each butterfly stage applies an arithmetic right-shift (division by 2) with **convergent rounding** (+0.5 LSB before truncation, computed in 16-bit intermediates). This introduces a cumulative pipeline gain of **1/64**. The output order is **bit-reversed**, which is the natural output order of Radix-2 DIF.

### Control State Machine

A 128-cycle frame controller lives in `project.v`:

| Phase | Cycles | Description |
|---|---|---|
| Idle | — | System waits for the trigger byte `0xAA` on `ui_in` while `ena` is high |
| Ingest | 0–63 | 64 real samples are clocked in from `ui_in` |
| Sync emit | Cycle 63 | A 2-stage slip buffer injects the sync marker `0xAA` on both outputs |
| Flush | 64–127 | `ui_in` is internally forced to `0x00`; 64 FFT bins stream out on `uo_out` (real) and `uio_out` (imaginary) simultaneously |
| Halt | 128 | `running` deasserts; system returns to idle |

Separating the ingest and flush phases into a strict 128-cycle frame prevents memory contamination between back-to-back transforms.

### Module Hierarchy

```
tt_um_fft_adityaamehra  (project.v)   — 128-cycle FSM, sync slip buffer, output gating
└── top                 (top.v)        — master_cnt counter, 6× sdf_stage instantiation
    └── sdf_stage × 6   (sdf_stage.v)  — delay line + butterfly + twiddle ROM per stage
        ├── delay_line  (delay_line.v) — parameterised shift register (depth = N/2^(stage+1))
        ├── Butterfly   (Butterfly.v)  — Radix-2 DIF complex butterfly with convergent rounding
        └── twiddle_rom (twiddle_rom.v)— 32-entry async ROM of W₆₄ coefficients
```

---

## How to test

### Basic operation

1. Assert `rst_n` low for at least one clock cycle to reset all pipeline registers and the frame counter.
2. Drive `ena` high.
3. Send the trigger byte `0xAA` (decimal 170) on `ui_in`. On the next rising clock edge the `running` flag asserts and the 128-cycle frame begins.
4. For cycles 0–63 (the ingest phase), clock 64 consecutive **8-bit signed real samples** into `ui_in`, starting from the cycle immediately following the trigger. Sample order is time-sequential (n = 0, 1, … 63).
5. After the ingest phase ends, the design asserts a sync marker (`0xAA`) on both `uo_out` and `uio_out` for one cycle. This signals that the next 64 output cycles will carry valid FFT data.
6. Read back 64 complex output samples from `uo_out` (real part, X_k real) and `uio_out` (imaginary part, X_k imag). **Note:** the bins arrive in bit-reversed order. To reconstruct natural frequency order, reverse the 6-bit index of each output sample.
7. After cycle 127, `running` deasserts and the design returns to idle, ready for the next `0xAA` trigger.

### Expected output characteristics

- **DC input** (constant value): energy appears only in bin 0 (index `0b000000`).
- **Unit impulse** (1 at n=0, 0 elsewhere): all 64 bins should have equal magnitude.
- **Single-tone sine/cosine** at frequency k₀: energy concentrated at bins k₀ and 64−k₀.
- **Magnitude scaling:** due to the per-stage /2 gain reduction, all output magnitudes are 1/64 of the unscaled DFT result. Account for this when comparing against a software FFT reference.
- **LSB deviation:** fixed-point quantisation and convergent rounding introduce ≤ 4 LSBs of error per bin relative to a floating-point reference (typical observed maximum ≈ 2 LSBs).

### Testbench

The included CocoTB test suite (`test/test.py`) validates the design against `numpy.fft.fft`. It exercises DC, unit impulse, single-tone sine, single-tone cosine, Nyquist, and pseudo-random noise inputs, and performs a point-by-point LSB deviation check after correcting for bit-reversal.

To run the tests locally:

```bash
cd test
make
```

---

## External hardware

The design requires an external controller (e.g., an FPGA or microcontroller) to:

1. **Generate the trigger sequence:** assert `ena`, then send `0xAA` on `ui_in` followed by 64 data samples on successive clock cycles.
2. **Capture output samples:** latch `uo_out` and `uio_out` on each of the 64 cycles following the `0xAA` sync marker.
3. **Bit-reverse correction (optional):** if natural frequency order is required, the controller or post-processing software should reorder the 64 captured bins by reversing their 6-bit indices.
4. **Clock supply:** the design targets a **10 MHz** system clock (100 ns period). The external controller must provide this clock on the `clk` pin.

No analog or mixed-signal peripherals are required. The interface is entirely synchronous digital.