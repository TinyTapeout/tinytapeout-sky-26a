<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Several basic test structures exist on chip for validation:

- Inverter

The primary structures for the chip

- Two Tunable Differential Ring Oscillators (~1GHz)
- 2 8-bit DACs for bias control
- Gilbert Cell Mixer
- 3/4 Modulus Prescaler
- Accumulator with mux'd output bit
- 12-bit counter with compare register
- Serial interface for control
    - Write Only
    - 2 address bits
        - 0 = RO VBIAS 0 / RO VBIAS 1
        - 2 = Accumulator 
        - 3 = Counter Compare

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
