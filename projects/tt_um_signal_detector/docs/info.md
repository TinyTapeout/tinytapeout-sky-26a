## How it works

This project implements a Ground Penetrating Radar (GPR) digital signal processor using Verilog for the Tiny Tapeout ASIC platform.

The design processes incoming radar echo samples and detects potential underground objects based on signal strength. The processor uses a simple digital signal processing pipeline consisting of:

FIR filter to reduce noise in the incoming radar signal

Envelope detector to extract the signal magnitude

Peak detector to identify strong reflections that may indicate buried objects

Radar samples are provided through the dedicated input pins. On every clock cycle, the processor filters the signal and evaluates whether the reflected signal exceeds a predefined threshold. If the threshold is exceeded, the system asserts an object detection flag on the output pins.

This design demonstrates a simplified version of digital radar signal processing and shows how DSP concepts can be implemented in a small ASIC design suitable for the Tiny Tapeout platform.

## How to test

1. Apply a clock signal to the design.

Provide radar echo sample values through the ui_in[7:0] input pins.

Enable the design by setting the enable (ena) signal high.

The processor will filter the incoming samples and compute the signal envelope.

When the processed signal exceeds the detection threshold, the object detection flag will be asserted on the output.

Outputs:

uo_out[7:1] – processed radar signal (envelope output)

uo_out[0] – object detection indicator

The functionality can also be verified through simulation using the provided Verilog testbench.

## External hardware

No external hardware is required. The design can be tested using simulation or through the Tiny Tapeout test infrastructure.<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.

