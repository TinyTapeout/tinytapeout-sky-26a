<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

DemosceneTTSKY is a fully autonomous VGA visual synthesizer. It generates a 640×480 @ 60 Hz video signal entirely from logic gates, with no RAM, ROM, or CPU.

- **VGA Timing Generator** – Two counters (`x` 0–799, `y` 0–524) create precise `hsync` and `vsync` pulses for a standard VGA monitor.
- **Render Engine** – Every pixel’s colour is computed on the fly using one of 8 hardwired bitwise equations that mix the `(x,y)` coordinates, a frame counter `t_frame`, and a shift amount. The equations use only shifts, XORs, ANDs, ORs, add/sub, and a single multiplication.
- **Autonomous Show Controller** – A 16‑bit Linear Feedback Shift Register (LFSR) generates pseudo‑random numbers. Every 60 frames (1 second) a new random value is captured and used to change:
  - the active visual equation (3 bits),
  - a global shift amount (3 bits),
  - the colour palette mapping (2 bits).
  This makes the chip a self‑directing “video jockey” that never repeats.
- **Palette Mapper** – The 8‑bit pixel value is mapped to 6‑bit RGB (RRGGBB) using one of four selectable palettes (natural, channel‑swapped, muted, inverted).
- **Audio Bytebeat** – A separate 16‑bit counter runs continuously. During the blanking intervals of the video signal, an 8‑bit audio sample is output on the bidirectional pins, driven by a Bytebeat formula `(high_byte >> shift) ^ (low_byte & mask)`. The audio parameters also change every second using the same LFSR.

## How to test

1. Provide a **25 MHz clock** on the `clk` pin.
2. Pull `rst_n` low for at least a few clock cycles, then release it high.
3. The chip will immediately start producing a VGA signal on `uo_out`:
   - `uo_out[7]` : vsync
   - `uo_out[6]` : hsync
   - `uo_out[5:0]` : RGB (2 bits per channel)
4. Connect these pins through a simple resistor‑DAC to a VGA monitor. You should see a 640×480 image with slowly evolving fractal patterns.
5. The LFSR automatically changes the visuals every second – no external switches required.
6. To observe the audio, connect the bidirectional pins `uio_out[7:0]` to a speaker via a DAC. During the video blanking periods, these pins output the Bytebeat audio. (The `uio_oe` signal is high during blanking, low during active video, so the pins are safe to share with other circuits.)
7. The `ui_in` control switches are not used by the autonomous mode, but you can connect them to override the LFSR for manual control if you later modify the design.

## External hardware

- VGA monitor (or a VGA‑to‑HDMI converter)
- 6‑bit resistor DAC for RGB (e.g., 2 resistors per channel: 330 Ω and 680 Ω on each of the 6 colour lines, plus 75 Ω termination in the monitor)
- Optional: audio amplifier + speaker (connected to a separate R2R DAC on the bidirectional pins, enabled only during blanking)
- 25 MHz crystal oscillator (provided on the Tiny Tapeout demo board)
