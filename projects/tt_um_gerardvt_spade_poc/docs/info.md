## How it works

This project generates a standard VGA colour bars test pattern at 640×480 resolution, 60 Hz refresh rate, using a 25 MHz pixel clock.

Eight colour bars fill the active display area, each 80 pixels wide, in the standard broadcast order from left to right:

| Bar | Colour   | R | G | B |
|-----|----------|---|---|---|
| 0   | White    | 1 | 1 | 1 |
| 1   | Yellow   | 1 | 1 | 0 |
| 2   | Cyan     | 0 | 1 | 1 |
| 3   | Green    | 0 | 1 | 0 |
| 4   | Magenta  | 1 | 0 | 1 |
| 5   | Red      | 1 | 0 | 0 |
| 6   | Blue     | 0 | 0 | 1 |
| 7   | Black    | 0 | 0 | 0 |

The design uses two counters — a horizontal pixel counter (0–799) and a vertical line counter (0–524) — clocked at 25 MHz. Both counters reset when `rst_n` is deasserted.

Sync signals are active low:
- **HSYNC**: low during horizontal counts 656–751 (96-pixel sync pulse, 16-pixel front porch)
- **VSYNC**: low during vertical counts 490–491 (2-line sync pulse, 10-line front porch)

Output is mapped to the Tiny Tapeout VGA PMOD standard on `uo_out[7:0]`:

| Bit | Signal | Bit | Signal |
|-----|--------|-----|--------|
| 7   | hsync  | 3   | vsync  |
| 6   | B0     | 2   | B1     |
| 5   | G0     | 1   | G1     |
| 4   | R0     | 0   | R1     |

Each colour channel is 2 bits (MSB and LSB set identically for full saturation). Pixels outside the active area (640×480) are blanked to black.

The design is authored in [Spade HDL](https://spade-lang.org) and compiled to SystemVerilog via `swim build` before synthesis.

## How to test

Connect a VGA monitor via the Tiny Tapeout VGA PMOD board plugged into the `uo` output port. Apply a 25 MHz clock to `clk`. Assert `rst_n` low briefly on power-up, then release it high.

The display should show eight vertical colour bars: White, Yellow, Cyan, Green, Magenta, Red, Blue, and Black, from left to right.

`ui_in` and `uio_in` are unused — their values have no effect on the output.

To test in simulation:

```bash
cd spade && swim build && cp build/spade.sv ../src/design.v && cd ..
cd test && make clean && make
```

A passing run reports `TESTS=3 PASS=3 FAIL=0`. Waveforms are written to `test/tb.fst` and can be inspected with GTKWave or Surfer.

## External hardware

- **Tiny Tapeout VGA PMOD** (plugged into the `uo` output port) — provides the VGA connector and resistor-ladder DAC
- **VGA monitor** — any standard monitor or capture card accepting 640×480 @ 60 Hz
