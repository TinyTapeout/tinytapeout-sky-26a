<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project renders a full-screen animated triangle-wave plasma effect on a VGA display at 640×480 resolution, 60 Hz refresh rate, using a 25 MHz pixel clock. The design is authored in [Clash HDL](https://clash-lang.org) — a Haskell-based hardware description language — and compiled to Verilog via `cabal exec clash` before synthesis.

### Plasma formula

The effect uses triangle-wave approximations of sine functions (no lookup table required). Three overlapping waves are evaluated at different spatial angles across the screen and summed into a single 8-bit plasma value. This value is mapped to 2-bit RGB with 120-degree phase offsets between the channels, producing 64 distinct colours per frame.

Four pattern variants are selectable via `ui_in[2:1]`:

| `ui_in[2:1]` | Pattern |
|---|---|
| `00` | Three-wave plasma (default) |
| `01` | Two-wave (horizontal + vertical) |
| `10` | Diagonal waves |
| `11` | XOR plasma |

### Colour mapping

The plasma value is split into three segments with 120-degree phase offsets and mapped to the R, G, B channels. The palette control (`ui_in[7:6]`) selects one of four colour mappings:

| `ui_in[7:6]` | Palette |
|---|---|
| `00` | RGB with 120° phase offsets (default) |
| `01` | Shifted hue |
| `10` | Fire |
| `11` | Greyscale |

With invert (`ui_in[5]`) high, the plasma value is complemented before colour mapping.

### Animation

An 8-bit frame counter advances once per frame, animating the plasma. The speed control (`ui_in[4:3]`) sets the counter step per frame. Asserting `ui_in[0]` freezes the counter — pattern, invert, and palette continue to render at the frozen frame.

### Input controls

All eight input pins are active and take effect concurrently:

```
  bit:  7   6   5   4   3   2   1   0
        |palette|inv|  speed  |pattern|pause
         [7:6]   [5] [4:3]   [2:1]    [0]
```

| Pin(s) | Field | Values |
|---|---|---|
| `ui_in[0]` | **Pause** | 1 = freeze animation, 0 = run |
| `ui_in[2:1]` | **Pattern** | `00` = three-wave · `01` = two-wave · `10` = diagonal · `11` = XOR plasma |
| `ui_in[4:3]` | **Speed** | Frame counter step: `00`=×1 · `01`=×2 · `10`=×4 · `11`=×8 |
| `ui_in[5]` | **Invert** | 1 = complement plasma value before colour mapping |
| `ui_in[7:6]` | **Palette** | `00` = RGB 120° · `01` = shifted hue · `10` = fire · `11` = greyscale |

### VGA timing

Standard 640×480 @ 60 Hz:
- **HSYNC**: active-low pulse during horizontal counts 656–751
- **VSYNC**: active-low pulse during vertical counts 490–491

Output is mapped to the Tiny Tapeout VGA PMOD standard on `uo_out[7:0]`:

| Bit | Signal | Bit | Signal |
|-----|--------|-----|--------|
| 7   | hsync  | 3   | vsync  |
| 6   | B0     | 2   | B1     |
| 5   | G0     | 1   | G1     |
| 4   | R0     | 0   | R1     |

## How to test

Connect a VGA monitor via the Tiny Tapeout VGA PMOD board plugged into the `uo` output port. Apply a 25 MHz clock to `clk`. Assert `rst_n` low briefly on power-up, then release it high.

You should see a full-screen animated colour plasma. Use the `ui_in` pins to interact with it in real time:

| `ui_in` value | Effect |
|---|---|
| `0x00` | Default: three-wave plasma, speed ×1, RGB palette |
| `0x01` | Freeze the animation at the current frame |
| `0x06` | Switch to two-wave pattern (`ui_in[2:1] = 01`) |
| `0x18` | Speed ×4 (`ui_in[4:3] = 10`) |
| `0x20` | Invert the plasma value |
| `0x40` | Shifted-hue palette (`ui_in[7:6] = 01`) |
| `0x80` | Fire palette (`ui_in[7:6] = 10`) |
| `0xC0` | Greyscale palette (`ui_in[7:6] = 11`) |
| `0xFF` | All controls: XOR plasma, speed ×8, inverted, greyscale, frozen |

Multiple pins may be set high simultaneously — all fields take effect concurrently.

To test in simulation:

```bash
scripts/build-clash.sh          # generate src/gvt_core.v
cd test && make clean && make
```

A passing run reports `TESTS=3 PASS=3 FAIL=0`. Waveforms are written to `test/tb.fst` and can be inspected with GTKWave or Surfer.

## External hardware

- **Tiny Tapeout VGA PMOD** (plugged into the `uo` output port) — provides the VGA connector and resistor-ladder DAC
- **VGA monitor** — any standard monitor or capture card accepting 640×480 @ 60 Hz
- Up to 8 push-buttons or DIP switches wired to `ui_in[7:0]` (optional, for interactive control)
