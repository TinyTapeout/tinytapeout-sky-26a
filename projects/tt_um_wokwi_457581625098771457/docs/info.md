<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

AND gates are connected to input 2,3,4,8. An S would be visible on the display if inputted correctly.

## How to test

Set the inputs and check the outputs match with the expected results:

| input 2 3 4 8 | output AND |
| ------------- | ---------- |
| 0 0 0 0       | 0          |
| 1 0 0 0       | 0          |
| 0 1 0 0       | 0          |
| 0 0 1 0       | 0          |
| 0 0 0 1       | 0          |
| 1 1 0 0       | 0          |
| 0 1 1 0       | 0          |
| 0 0 1 1       | 0          |
| 1 0 0 1       | 0          |
| 0 1 0 1       | 0          |
| 1 0 1 1       | 0          |
| 1 1 1 1       | 1          |

## External hardware

External hardware used are 7 segment display, and clock and reset.
