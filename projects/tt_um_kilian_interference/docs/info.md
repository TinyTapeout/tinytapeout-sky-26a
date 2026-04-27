## How it works

Wave Lattice is a port of Taylor Troesh's browser sketch at
<https://taylor.town/waves> (itself inspired by Zach Lieberman) to pure
silicon logic. A 40×30 grid of dots is drawn against a black background
over VGA. Two radial wave sources interfere across the screen; where
each dot would land is displaced by that interference field, so the
regular lattice warps into compression rings around the sources.

A single virtual "pointer" slowly traces a Lissajous figure (3:5
frequency ratio between the x and y axes) within a ±64-pixel box
around screen centre, completing one full woven cycle every ~17
seconds. Source A sits at the pointer, source B at its point-mirror
`(640-x, 480-y)` — directly analogous to the JS original where the
second source is the mirror of the mouse position.

### 2× internal clock

To fit the design into a single Tiny Tapeout tile, the internal logic
runs at **50.35 MHz — twice the 25.175 MHz VGA pixel rate**. A 1-bit
`phase` register toggles every clock, splitting each VGA pixel into two
internal cycles:

- `phase = 0` — *pixel cycle*: VGA timing advances, source A's state
  updates, the output is sampled to the screen.
- `phase = 1` — *free cycle*: source B's state updates.

A single 14-bit adder, subtractor, or predicate whose operands are
muxed on `phase` replaces what would otherwise be two parallel copies
(one for A, one for B). Only the state registers remain duplicated
(r1a/r1b, r2a/r2b, ra_lat/rb_lat, signed / far-from-axis latches) —
they have to, because both values are read simultaneously when the
display-time displacement field is decoded.

### Interference field

The interference surface is computed per-pixel by a distance-squared
accumulator trick that avoids any multipliers on the hot path — just
adders and an XOR-like phase extraction. Displacement direction comes
from the sign of the (already-signed) pixel-to-centre delta;
displacement magnitude from the phase bits of the accumulator, with
one of those bits acting as a sign that flips across each radial ridge
(the silicon equivalent of `tanh(sharp · sin)` in the JS original —
dots *compress* onto ridges and *rarefy* in troughs).

There is no frame buffer, no line buffer, and no per-dot state: the
only storage is the two 14-bit accumulators per source, a pair of
12-bit lattice-anchor latches, and the counter needed for the
Lissajous trajectory.

## How to test

Connect a TinyVGA Pmod to the output pins. The design expects a
**50.35 MHz** clock (2× the VGA pixel rate). After reset you should
see a field of white dots on black, warping around the two source
centres as the pointer weaves a slow Lissajous figure through the
centre of the screen. All input pins are unused in this variant.

## External hardware

TinyVGA Pmod (VGA output)
