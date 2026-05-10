# Trinity GF16 Dot Product

GF16 (Golden Float 16-bit) dot product N=4 accelerator with phi-structured bias=31 encoding.

## How it works

The design computes a 4-element dot product in GF16 format:
- 4 parallel GF16 multipliers (combinational, with DSP-style booth encoding)
- 3 GF16 adders in tree reduction: p0+p1 → s01, p2+p3 → s23, s01+s23 → result
- GF16 format: 1 sign + 6 exponent (bias=31) + 9 mantissa

The default computes dot4([1,2,3,4], [1,2,3,4]) = 30.0 = 0x47C0.

## How to test

After reset, the output should show:
- `uo_out` = 0xC0 (result low byte)
- `uio_out` = 0x47 (result high byte)

Combined: 0x47C0 = GF16(30.0)

## External hardware

No external hardware required. Directly observable on the output pins.
