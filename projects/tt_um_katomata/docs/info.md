<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Katomata is a Tiny Tapeout **demoscene entry**: a 1D elementary cellular
automata visualizer for VGA. It implements Stephen Wolfram's
classification of *Elementary Cellular Automata* and continuously cycles
through **all 256 rules (rule 0 through rule 255)**, drawing the time
evolution of each rule directly on a 640x480 @ 60 Hz VGA frame.

### Cellular automata, briefly

A 1D elementary cellular automaton is a row of binary cells that evolves
in discrete steps. The next state of each cell is decided by its own
state and that of its two immediate neighbours - three bits in, one bit
out, so 2^3 = 8 input patterns and one output bit per pattern. Packing
those 8 output bits into a byte gives 2^8 = 256 possible "rules",
numbered 0-255. Rule 30 (the default starting rule here) is famously
chaotic; rule 90 produces a Sierpinski triangle; rule 110 is Turing
complete.

### What you see on screen

- A row of **32 cells** spans the visible width of the frame (each cell
  is 20x20 pixels).
- Each successive row of the screen is the **next generation** of the
  automaton, computed combinationally from the row above by the
  `automata_engine` module using the current rule byte.
- The active rule is held for **100 frames (~1.67 s)**, then advances
  by one. After rule 255 it wraps back to rule 0.
- Halfway through each rule's display the seed pattern is inverted, so
  every rule is shown both starting from a single black cell on white
  and a single white cell on black.
- Foreground/background colors are derived from the current rule byte,
  so each of the 256 rules has a distinct look.
- The bottom 20-pixel strip is a **rule indicator**: it shows the
  current rule number in binary as 8 large cells, MSB on the left.

### Modules

- `tt_um_katomata` (top): VGA pipeline, framing logic, rule sequencer,
  color mapping.
- `hvsync_generator`: standard 640x480 @ 60 Hz horizontal/vertical sync
  generator (with an added `vmaxxed` end-of-frame strobe).
- `automata_engine`: pure-combinational 1->1 row update for the
  selected rule byte.
- `counter_gen`, `pos_edge_detect`, `neg_edge_detect`: small reusable
  helpers.

## How to test

1. Plug a [TinyVGA Pmod](https://github.com/mole99/tiny-vga) into the
   output Pmod connector of the Tiny Tapeout demo board.
2. Drive `clk` with a **25.175 MHz** pixel clock.
3. Hold `rst_n` low briefly to reset, then release.
4. Connect a VGA monitor. You should see the cellular automata rules
   scrolling top-to-bottom, with the rule indicator strip across the
   bottom of the screen advancing roughly every 1.67 seconds.

There are no input pins to drive - all 8 `ui_in` and 8 `uio_in` bits
are unused.

## External hardware

- [TinyVGA Pmod](https://github.com/mole99/tiny-vga) on the output Pmod
  connector.
- A VGA monitor.
