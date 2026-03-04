<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A way of estimating resistance for external sensors without a mixed signal ADC. Excites an external RC cicuit with a step, and measures the time taken for the circuit to rise. This rise is assumed to be when input digital pin that is connected to the analogue RC rising voltage flips from 0 to 1. Uses this time to calculate resistance.

## How to test

First pulse the reset high, then once the circuit is enabled, will output step voltage, measure time for step input to be seen and then will output 32 bit calculated resistance value via the uart pin.

## External hardware

Only require a resistor and 10 nF capacitor.
