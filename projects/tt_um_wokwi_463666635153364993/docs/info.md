<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project features two independent digital modules within a single ASIC tile:
1. **Hexadecimal Up-Counter:** A 4-bit ripple counter that increments on every rising edge of the clock. It provides raw binary outputs (COUNT_B0 to COUNT_B3) representing values from 0 to F.
2. **Programmable Logic Validator:** A combinational circuit that evaluates Boolean functions based on two data bits (BIT_A, BIT_B) and two control bits (CTR_1, CTR_2).
  - **Selection Logic:**
    - 00: AND (A & B)
    - 01: OR (A | B)
    - 10: XOR (A ^ B)
    - 11: NOT (~A)

  - **Modifiers:** INV (Bit 4) enables a final NOT stage (turning AND to NAND, etc.), and EN (Bit 5) enables the output (Low = Active, High = Force to GND).
  - **Signal Buffers:** Two independent paths (BUFF1 and BUFF2) route input signals through internal silicon delay chains to verify path integrity.

## How to test
* **Counter:** Apply a pulse to the clock pin and monitor uo[0:3]. The binary sequence should increment from 0000 to 1111. Use the rst_n pin to clear the count to zero.
* **Logic Unit:**
  1. Set EN (ui[5]) to 0.
  2. Set CTR_1 (ui[2]) and CTR_2 (ui[3]) to the desired gate code.
  3. Toggle BIT_A and BIT_B to verify the truth table at LOGIC_OUT (uo[4]).
  4. Toggle INV (ui[4]) to verify the result is negated.
* **Buffers:** Ensure signals at ui[6:7] are replicated at uo[5:7].

## External hardware
* **7-Segment Display:** An external decoder (like a 74HC4511 or similar) is required to convert the raw COUNT_B0-B3 bits into a human-readable hex display.
* **Logic Indicators:** 1 LED for monitoring output from the logic lab. Also, LEDs for the buffers evaluation.
* **Input Controls:** DIP switches for the 8-bit input bus and a push-button for manual clock stepping or a clock signal.
