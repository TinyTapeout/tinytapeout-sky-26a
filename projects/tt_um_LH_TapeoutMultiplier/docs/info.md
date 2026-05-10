<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project implements an 8-bit signed baugh-wooley multiplier.
The two input operands are provided through:

ui_in -> first operand (A), 
uio_in -> second operand (B)

The Baugh-Wooley Architecture
The multiplier generates partial products using bitwise AND operations between the bits of A and B. These partial products are arranged in a grid and shifted according to their bit positions.
The shifted partial products are then summed using a tree reduction structure to produce the final 16-bit result
A correction bit pattern is then applied to correct for two-complement signed multiplicaiton.

The final product is split across the outputs:

uo_out → lower 8 bits of the result, 
uio_out → upper 8 bits of the result

## How to test

To test the multiplier:

Apply two 8-bit signed values:

Put operand A on ui_in, 
Put operand B on uio_in

Wait for one clock cycle

Read the result:

Lower 8 bits from uo_out
Upper 8 bits from uio_out

Combine them to get the full 16-bit signed result

Example:

Input:
ui_in = 20, uio_in = 30
Output:
{uio_out, uo_out} = 600

The design supports both positive and negative values using two’s complement representation.

## External hardware

None
