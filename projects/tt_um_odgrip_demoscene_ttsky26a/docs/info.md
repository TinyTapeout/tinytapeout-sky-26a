<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a small demoscene-style VGA generator designed for Tiny Tapeout.

It generates a 640x480 @ 60Hz video signal using simple raster timing logic and outputs it through the VGA PMOD interface. The image is computed entirely in hardware using combinational logic, without any frame buffer or external memory.

The visual consists of:
- A procedurally generated animated background using XOR patterns
- A central logo inspired by the Tiny Tapeout mark:
  - A circular shape with a black outline
  - A solid white fill
  - Two stylized "T" letters rendered in black inside the circle

The circle is computed using a squared distance approximation (dx² + dy²), while the letters are built from rectangular regions. This keeps the design simple and synthesizable while still producing a recognizable graphic.

The design uses reduced-resolution coordinates internally to minimize logic usage, resulting in a pixelated / retro visual style similar to classic demoscene effects.

---

## How to test

1. Connect a VGA PMOD to the Tiny Tapeout demo board
2. Power the board and select the project using the Tiny Tapeout commander
3. Reset the design

You should see:
- An animated background
- A central circular logo with two black "T" letters inside

Optional controls via `ui_in`:
- `ui_in[0]`: invert colors
- `ui_in[1]`: freeze the logo at the center of the screen

---

## External hardware

- VGA PMOD (required for video output)

No additional hardware is required.
