<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

AND, OR and XOR gates are connected, each state has an LED informing the data status.

A puzzle to work out how to set the switches to get the last led to light up.

## How to test

By switching different input, the LEDs will switch on consecutively, and try to get the last LED light up.

| input 0 to 7 | output AND | output OR | output AND 2 | output XOR |
---------------------------------------------------------------------
|   00000000   | output AND | output OR | output AND 2 | output XOR |
|   00000001   | output AND | output OR | output AND 2 | output XOR |
|   00000010   | output AND | output OR | output AND 2 | output XOR |
|   00000011   | output AND | output OR | output AND 2 | output XOR |
|   00000100   | output AND | output OR | output AND 2 | output XOR |
|   00000101   | output AND | output OR | output AND 2 | output XOR |
|   00000110   | output AND | output OR | output AND 2 | output XOR |
|   00000111   | output AND | output OR | output AND 2 | output XOR |

## External hardware

LED display
