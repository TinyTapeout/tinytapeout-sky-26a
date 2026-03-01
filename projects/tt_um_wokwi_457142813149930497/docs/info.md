<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Eight input switches (IN0–IN7) feed the input bus.

Two selected inputs (IN1 and IN2) are routed into an AND gate whose output is sent to the output block.

Two divided clock signals are taken from the counter stages and routed to output pins and to the 7-segment display driver.

A reset push button clears the chain to zero.

The outputs are connected to:

Logic output (AND result)

Divided clock outputs

7-segment display segments


## How to test
Test the AND logic

Set the two selected input switches high or low.

Verify the AND truth table:

| A | B | AND |
|---|---|-----|
| 0 | 0 |  0  |
| 0 | 1 |  0  |
| 1 | 0 |  0  |
| 1 | 1 |  1  |

The AND output should only be high when both inputs are high.
