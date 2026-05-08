<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This design uses a 16-bit cascading counter as a time variable (t). This variable is fed into a multiplexer that selects between 8 different bitwise mathematical algorithms. By applying shifts, XORs, and additions, the hardware generates complex, non-linear patterns without the need for memory or pre-stored images.

## How to test
1. Apply a 10MHz clock and pulse `rst_n` low to reset the counter.
2. Use input pins `ui[7:5]` to select one of the 8 patterns.
3. Use input pins `ui[2:0]` to change the 'shift amount' which alters the frequency/scale of the pattern.
4. Toggle `ui[3]` to apply a bitmask to the lower byte of the output.
5. Monitor `uo[7:0]` on an oscilloscope or R2R DAC to see the generated waveform.

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
