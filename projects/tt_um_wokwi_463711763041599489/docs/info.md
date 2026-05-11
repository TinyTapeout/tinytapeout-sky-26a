<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
The circuit utilizes a chain of D Flip-Flops (flop1 through flop18) and Multiplexers to form a large Parallel-In-Serial-Out (PISO) shift register. When the control switch is set to "Load," the input ASCII bits are captured into the register chain. Once switched to "Transmit," the data is shifted serially bit-by-bit through the uo_out[7] pin, automatically including the necessary start, stop, and idle bits to form a valid UART frame.

## How to test
1. Set the desired ASCII value (between 0x40 and 0x5F) using the input DIP switches.
2. Toggle the Load switch (ui_in[6]) and pulse the clock to capture the data into the registers.
3. Set the switch to TX mode to begin the serial transmission.
4. Monitor the serial output on pin uo_out[7] and observe the status LEDs to verify the sequence.

## External hardware
- 8-position DIP switch for data and mode selection.
- Common cathode 7-segment display for debugging.
- Status LEDs to monitor the bit shifting process.
- A logic analyzer or UART-to-USB converter to verify the serial signal on a PC.
