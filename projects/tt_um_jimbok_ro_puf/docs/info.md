<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a Physically Unclonable Function (PUF) based on ring oscillator (RO) frequency comparisons. It generates a chip-unique fingerprint by exploiting random manufacturing variations between nominally identical oscillators.

The design contains 16 ring oscillators instantiated from the SKY130 cell library. When the device is triggered, it performs all (16C2) = 120 pairwise comparison by feeding the selected oscillators into a counter. For each RO i, the FSM counts the number of later ROs (j>i) that it beat, and the count is stored as a 49-bit Lehmer code.

The result is read out over a simple SPI slave interface (mode 0, MISO only - the chip ignores MOSI). The busy pin is high while the FSM runs. The 'done' pin rises when the result is ready, and falls when the master begins a read (CS falling edge).


## How to test

1) Apply power and release reset
2) Hold CS high (idle)
3) Send a pulse on the 'start' pin. The FSM begins on the falling edge of 'start'
4) Wait for 'busy' to fall, and 'done' to rise. May take a few ms, to a few hundred ms
5) Read the result: drive CD low, and clock 49 bits out with MISO and SCK. MISO shifts out the MSB first.
6) Raise CS. The chip is ready for another pulse on 'start', which should produce near-identical results on the same chip, but different results on other chips.

## External hardware

Only requires a connected microcontroller.
