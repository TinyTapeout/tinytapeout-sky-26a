<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a Tiny Tapeout demoscene entry. It generates a 640x480 @ 60 Hz
VGA signal and draws a 64x64 white square that bounces around the visible
area on a dark-blue background, flipping its direction whenever it hits an
edge of the screen.

Internally the design contains:

- `hvsync_generator` (taken from the
  [TinyTapeout vga-playground](https://github.com/TinyTapeout/vga-playground/blob/main/src/examples/common/hvsync_generator.v))
  produces standard VGA sync pulses (active-low HSYNC and VSYNC), a
  `display_on` strobe, and 10-bit `hpos`/`vpos` pixel coordinates.
- A bouncing-box state machine that updates the box's `(x, y)` position
  by 2 pixels per frame (on the last pixel of each frame) and reverses
  direction when an edge is reached.
- A pixel pipeline that outputs white inside the box, dark blue outside
  it, and black during blanking, mapped to the TinyVGA Pmod's 6-bit RGB
  pinout.

## How to test

1. Plug a [TinyVGA Pmod](https://github.com/mole99/tiny-vga) into the
   output Pmod connector of the Tiny Tapeout demo board.
2. Drive the design with a 25.175 MHz pixel clock (or run the on-board
   clock generator at that frequency).
3. Connect a VGA monitor; you should see a white square bouncing around
   on a dark-blue background.

There are no input pins to drive - the demo runs entirely from the clock
and the active-low reset.

## External hardware

- [TinyVGA Pmod](https://github.com/mole99/tiny-vga) on the output Pmod
  connector.
- A VGA monitor.
