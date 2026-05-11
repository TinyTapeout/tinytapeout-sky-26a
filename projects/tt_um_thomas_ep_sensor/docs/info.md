<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is an analog **chiral exceptional-point (EP) sensor** built around two
nominally-matched on-chip LC tanks at ~2.7 GHz, coupled in one direction
through an NMOS source follower (Mf) and a coupling MIM cap (Cc).  Following
Zhao *et al.*, the unidirectional coupling places the two-mode system on the
exceptional-point line of its eigen-spectrum; a small capacitive perturbation
ε on the V1 tank then produces a frequency splitting Δf in the V2 spectrum
that scales as **Δf ∝ √ε**, giving substantial sensitivity gain over a
conventional reciprocally-coupled resonator pair.

### Block diagram

```
   ua[0] ── L1 ── V1 ──┬──CT1── VGND        ┌── L2 ── V2_in ──┬── CT2 ── VGND
                       │                    │                 │
                       └── Cv-array (8b) ──┘ ↑                ├── Cc
                       │                     │                │
                       Cac_in                ↑                ↓
                       │                  (one-way)         Vfo (Mf source)
                       Mf gate             coupling          ↑
                       (source follower)                     ┘
                                                            
                                                          V2_in ── Mout (V2 buffer) ── ua[1]
```

* **L1, L2** — custom 130 × 130 µm square spirals on m4+m3+m2 stack;
  L = 1.351 nH, Q ≈ 15 (FastHenry-extracted).
* **CT1, CT2, Cc** — MIM caps tuned for the Zhao-exact EP point at
  κ = 0.3125, sized for the L = 1.351 nH tank.
* **8-bit cv-array** — binary-weighted MIM caps (20, 40, 80, 160, 320, 640,
  1280, 1280 fF) switched in via LVT NMOS.  Asserting `ui_in[i]` adds the
  i-th bit to the V1 tank.
* **Source-follower Mf** — W = 400 µm × L = 0.15 µm, 80 fingers — drives Vfo
  with V1's signal, capacitively coupled to the V2 tank through Cc.  This
  is the unidirectional element: V1 → V2, but not V2 → V1.
* **V2 output buffer (Mout)** — W = 200, nf = 40 source follower; isolates
  the V2 tank from the bench probe (5 pF + 50 Ω) so the two Zhao peaks
  remain resolvable post-bondwire.
* **On-chip bias dividers** — poly resistor stacks generate Vbn = 1.20 V
  (source-follower tail) and Vbmid = 1.50 V (gate-bias for Cac coupling).
  No external bias pins required.

### Analog pinout

| Pin   | Name | Function |
|-------|------|----------|
| ua[0] | V1   | V1 LC-tank node.  Drive an AC test signal here through 50 Ω; the L1 spiral plus tank caps establish resonance. |
| ua[1] | V2   | V2 LC-tank buffered output.  Observe the |S21|^2 spectrum here — peaks split as ε grows above the EP. |

### Design verification

* DRC clean (KLayout, sky130A_mr.drc, feol/beol/offgrid all 0).
* LVS topologically equivalent to schematic (225 devices match).
* Schematic-level Monte Carlo (500 trials, ±5 % cap, ±10 % L, ±50 mV bias):
  100 % yield in the [0.45, 0.55] target slope band.
* Post-layout robustness: realistic parasitic injection causes a uniform
  ~0.5 % frequency shift; EP scaling preserved bit-for-bit.

## How to test

This is an RF analog sensor.  You will need:

1. **Tiny Tapeout demo board + breakout PCB** with u.fl connectors on
   ua[0] (V1) and ua[1] (V2).  The u.fl jacks are RF-rated to 6 GHz.
2. **A vector network analyzer** that reaches at least 3 GHz with > 60 dB
   dynamic range.  A Keysight P5004A (9 kHz – 20 GHz, 135 dB DR) is ideal.
   An Analog Discovery 3 will *not* work — its 30 MHz bandwidth is far below
   the chip's 2.7 GHz operating point.
3. **VDPWR = 1.8 V**, all `ui_in` pins routed from a microcontroller or
   manual switches to set the cv-array perturbation code.

### Procedure

1. Power up the chip.  Bias generation is on-chip, no setup required.
2. Connect VNA port 1 to ua[0], port 2 to ua[1].  Calibrate.
3. Sweep S21 magnitude from 1.5 GHz to 4.5 GHz with `ui_in = 0x00`.
   Locate the resonance — expected near 2.71 GHz.  This is the EP-degenerate
   peak (κ tuned to put the two modes coincident).
4. Step the cv-array code:
   `ui_in = 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0xC0`.
5. For each code, locate **two** local peaks in |S21|^2 and record their
   separation Δf.
6. Plot log(Δf / f₀) vs log(ε) where ε = Ce / (2 C_total).  The slope should
   be ≈ 0.5 ± 0.05 across the operating window — the canonical EP signature.

If the slope departs significantly from 0.5, the chip is operating away
from the EP (κ off-target), but the cv-array sweep is still informative as
a relative perturbation indicator.

## External hardware

* Tiny Tapeout breakout PCB (u.fl variant; supports RF-rated probing).
* Microcontroller (Pi Pico on the demo board is fine) or manual switches
  to drive `ui_in[7:0]`.
* Vector network analyzer (Keysight P5004A or equivalent).
* Two SMA → u.fl pigtails.
