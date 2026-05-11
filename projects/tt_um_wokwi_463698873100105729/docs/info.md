<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project implements an 8-bit Pattern Comparator that functions as a digital lock. The circuit acts as a judge, validating whether the user has entered the correct "Master Key" via an external 8-bit DIP switch.

**Internal Logic Architecture:** To ensure a robust and educational design, the IC utilizes a bit-matching architecture:
1. **Key Definition:** A specific 8-bit sequence is hard-coded into the silicon (10110101).
2. **Bit-Wise Inversion:** For every input bit where the master key requires a '0', an internal NOT gate (inverter) is placed. For bits requiring a '1', the signal is routed directly.
3. **The Super-AND Validator:** All eight signals (inverted and direct) are fed into a high-order 8-input AND gate tree (constructed from a cascade of 2-input standard AND gates).
4. **Final Result:**
  - Success: If the input perfectly matches the master key, the final AND gate outputs a logic '1', lighting up the Green LED.
  - Failure: If even a single bit differs, the output remains '0', triggering a Red LED via an additional inverter.

**Logic Table for the master key:** The circuit is programmed to recognize the following binary pattern (from MSB to LSB):

| Pin | Bit Weight | Key Value | Internal Logic |
| :--- | :--- | :---: | :--- |
| **ui_in[7]** | MSB (128) | **1** | Direct Wire |
| **ui_in[6]** | 64 | **0** | **NOT Gate** |
| **ui_in[5]** | 32 | **1** | Direct Wire |
| **ui_in[4]** | 16 | **1** | Direct Wire |
| **ui_in[3]** | 8 | **0** | **NOT Gate** |
| **ui_in[2]** | 4 | **1** | Direct Wire |
| **ui_in[1]** | 2 | **0** | **NOT Gate** |
| **ui_in[0]** | LSB (1) | **1** | Direct Wire |

## How to test
1. **Power Up:** Ensure the chip is powered and the ena (enable) pin is high.
2. **Initial State:** Set all DIP switches to '0'. The Red LED (uo_out[1]) should be ON, indicating an incorrect code.
3. **Entering the Code:** Toggle the switches to match the secret key. Note that the physical switches on a standard Wokwi/PMOD block are usually ordered from ui_in[0] (Left) to ui_in[7] (Right). To enter the key 10110101 (MSB to LSB), set the switches to: 1 0 1 0 1 1 0 1 (Left to Right).
4. **Verification:** Once the correct pattern is set, the Green LED (uo_out[0]) will turn ON, and the Red LED will turn OFF.

## External hardware
- **8-Position DIP Switch:** Connected to the input bus ui_in[7:0].
- **Green LED:** Connected to uo_out[0] (Success indicator).
- **Red LED:** Connected to uo_out[1] (Failure indicator).
- **Resistors:** Two 220Ω resistors for the LEDs or your resistors values.
