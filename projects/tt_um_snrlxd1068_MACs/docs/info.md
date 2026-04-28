<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project implements a dual-mode **Multiply-Accumulate (MAC)** unit supporting both Linear and Logarithmic Number Systems. To accommodate the 8-bit I/O constraints of the Tiny Tapeout platform, the design utilizes a time-division multiplexed interface: two 8-bit operands are ingested over two consecutive clock cycles, while the internal 32-bit accumulation result is serialized and driven onto the 8-bit output pins over a span of four cycles.


The architecture supports two distinct operational modes:

* **Linear Mode:** Processes standard **signed 8-bit** integers to produce a high-precision **signed 32-bit** accumulated sum.
* **Logarithmic Mode:** Operates on a specialized 8-bit format consisting of 1 sign bit and 7 bits representing the magnitude as $\log_2(|x|)$ in **Q3.4** fixed-point format. The resulting 32-bit output consists of 1 sign bit and 31 bits in **Q5.26** fixed-point format, offering an expansive dynamic range and high precision for complex arithmetic operations.