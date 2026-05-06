<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The core of this project is a quasi-asynchronous interconnect. Data is streamed in through an SPI interface, then the data is sent between from the TX to the RX, with an ACK signal between each transaction. After completion, data is streamed out of the SPI interface.

Instead of standard NULL convention where the TX and RX lines go low after each transaction, we instead read toggles on each line as a representation of new data. This essentially halves the switching rate of the TX-RX lanes with some minor added logic on the decoder and encoder.

As an example, observe the following transaction:
- T=time : TX-RX data : decoded value
- T=0    : `4'b0110`    : `X`
- T=1    : `4'b1110`    : `2'b11`
- T=2    : `4'b1100`    : `2'b01`
- T=3    : `4'b1100`    : `X`

Here, the value `4'b0111` would be recieved on the RX side.

## How to test

Connect the RX and TX sides together by tying `UI[4:0]` to `UO[4:0]`.\
Note that with two chips, you can instead tie the chips together.

The asyncronous interconnect is then controlled by the following steps:
0. Preform an active low reset
1. Hold the CAPTURE line (`UIO[7]`) high
2. Stream data over the SPI interface\
  2.1. MOSI (input) is `UI[7]`\
  2.2. SCLK is `UIO[6]`\
  2.3. MOSI gets read on posedge of SCLK
3. Pulse the LOAD line to start (`UI[5]`)
4. TX and RX are now communicating
5. When VLD (`UO[6]`) goes high, drop the CAPTURE line
6. Stream RX data over the SPI interface\
  6.1. MISO (output) is `UO[7]`\
  6.2. MISO gets shifts on negedge of SCLK
7. After data is recieved, pulse the RDY line (`UI[6]`)
8. Once DONE (`UO[5]`) is asserted, restart from step 1

Note: steps 2 and 6 can be done at the same time, but step 1 must still be repeated on the next cycle.\
It is also possible to instead pulse the CAPTURE line before reading the RX data.

## External hardware

None.
