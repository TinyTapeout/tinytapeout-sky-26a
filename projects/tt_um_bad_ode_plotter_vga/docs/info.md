<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a very, very bad plotter of select systems of 2 ODEs.

The system graphed is shown below:
```
dx/dt = ax + by
dy/dt = cx + dy
```

Where, for now, the coefficients are fixed to
```
a = 0
b = -1
c = 1
d = 0
```

## How to test

After starting project, bring reset from low to high in order to begin the plotting.

Then watch as the point gets plotted according to the above ODE.

To reset the plot from the start, simply cycle `rst_n`.

## External hardware

Uses the [TinyVGA PMOD](https://tinytapeout.com/specs/pinouts/#vga-output) connected to the dev board's `OUT` header.
