<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project exposes an enable-controlled smartcard PLL model through the Tiny Tapeout interface.

- The Tiny Tapeout `clk` pin is used as the PLL reference input.
- `ui[0]` is the PLL enable control. When `ui[0]=1` and `ena=1`, the PLL logic runs.
- `ui[7:4]` configures divider ratio for the feedback path.
- `uio[3:0]` configures charge pump gain.
- The main output and divided clocks are exported on `uo[4]`, `uo[3]`, and `uo[2]`.
- Lock status is exported on `uo[0]` and `uo[1]`.

Operational intent:

- Turn ON by asserting `ena=1`, releasing reset (`rst_n=1`), and setting `ui[0]=1`.
- Turn OFF by setting `ui[0]=0` (intentional disable).
- After disable, clock outputs are expected to stop and lock status should drop.

## How to test

1. Go to the `test` folder.
2. Run RTL simulation:

```sh
make -B
```

3. The cocotb test checks three key behaviors:
	- PLL output does not toggle while disabled.
	- PLL output toggles after explicit enable.
	- PLL output stops again after explicit disable.

You can inspect waveforms using GTKWave:

```sh
gtkwave tb.fst tb.gtkw
```

## External hardware

No external hardware is required for RTL verification.
