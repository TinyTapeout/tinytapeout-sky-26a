<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Structures currently implemented:
- Inverter (Test Structure)
- 3/4 Modulus Prescaler

Structures still to be implemented:
- Two Tunable Differential Ring Oscillators (~1GHz)
- 2 8-bit CSDACs for bias tuning
- Gilbert Cell Mixer
- Accumulator with mux'd output bit
- 12-bit counter with compare register
- Serial interface for control
    - Write Only
    - 2 address bits
        - 0 = RO VBIAS 0 / RO VBIAS 1
        - 2 = Accumulator 
        - 3 = Counter Compare

## How to test

Input 7 is connected to Output 7 via an inverter, if this doesn't work there are bigger problems!

Input 0 controls the division factor of a clock prescaler, and Output 0 will either be CLK/4 or CLK/3 to be verified using an Oscilloscope.

## External hardware

- Oscilloscope 