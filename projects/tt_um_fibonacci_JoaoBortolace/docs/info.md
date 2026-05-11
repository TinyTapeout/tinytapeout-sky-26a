<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Fibonacci 7-Segment Display Controller
A 16-bit Fibonacci sequence generator with a Binary-to-BCD converter and a multiplexed 5-digit 7-segment display driver.

## How it works

This design calculates the Fibonacci sequence up to 16 bits (max value 46,368 before overflow). The process is divided into four main stages:
1.  **Fibonacci Core**: A synchronous counter that calculates the next number in the sequence (`n = n-1 + n-2`) whenever an external pulse is detected.
2.  **Binary-to-BCD (Double Dabble)**: Since 7-segment displays require decimal digits, a Double Dabble algorithm converts the 16-bit binary value into five 4-bit BCD (Binary Coded Decimal) nibbles. This conversion takes exactly 17 clock cycles.
3.  **Multiplexer**: A Ring Counter rotates a "one-hot" bit to enable one of the 5 digits at a time, synchronized with the main clock.
4.  **7-Segment Decoder**: A combinational block that converts the current BCD nibble into the standard `gfedcba` pattern for the display.

The design includes a **synchronizer** and **edge detector** on the manual step input to ensure stable operation even with mechanical buttons.

## How to test

1.  **Clock**: Provide a slow clock (around 1kHz) to the `clk` pin. This ensures a flicker-free multiplexing frequency of 200Hz per digit.
2.  **Reset**: Apply a low pulse to `rst_n` to initialize the sequence to 0.
3.  **Manual Step**: Pulse the `ui_in[0]` pin to calculate and display the next Fibonacci number.
4.  **Observation**: 
    *   `uo_out[6:0]` will show the segments (active high).
    *   `uo_out[7]` (Ready Flag) will blink low during the 17ms conversion time.
    *   `uio_out[4:0]` will scan through the 5 digit enables.
      
## External hardware

To fully interact with this design, you will need the following component:

1.  **7-Segment Display (5 Digits)**:
    *   **Type**: Common Cathode.
    *   **Multiplexing**: The display must have shared segment pins (a-g) and individual Digit Enable pins (Anodes/Cathodes). Each pin should have a current limiting resistor.
    *   **Transistor Driver**: A transistor must be used on the common cathode pin of each display to enable it to be turned on and off. 
    
