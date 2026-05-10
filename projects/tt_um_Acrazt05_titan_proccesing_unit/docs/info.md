<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

- The Titan Processing Unit (TPU) fethces instructions via SPI from an off-chip Memory module. This module stores the ROM and RAM partitions. The instructions are executed by the CPU once the data is received. This CPU is a working implementation of the Hack computer from the Nand2Tetris course (with some modifications for phyisical feasibility). More details will come soon.

## How to test

- Load programs for the computer to run to the RP2040 ROM section (0000 to 7FFE). We will release a tool for this.

## External hardware

- Simulated SPI RAM on RP2040 by Michael Bell.
