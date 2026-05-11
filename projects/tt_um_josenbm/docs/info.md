<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project implements a 9-channel oscillator frequency measurement ASIC with programmable gate time, SPI-controlled DAC outputs, and SPI-based ADC sampling. The device is controlled over I²C.

Each oscillator input is counted over a programmable time window derived from the 50 MHz system clock. After the gate interval completes, the counts are latched into a snapshot register bank accessible via I²C.

Two DAC channels are programmed via I²C and transmitted over SPI. An external 12-bit SPI ADC is periodically sampled and included in the measurement snapshot stream.


## How to test
1. Apply 1.8 V supply and provide a 50 MHz clock.
2. Release reset.
3. Confirm I²C device responds at address 0x2A.
4. Enable counting by writing:

   REG 0x04 = 0x11

5. Program gate time:

   Write 32-bit gate_cycles to 0x20–0x23  
   Write 0x27 = 0x01 to apply  

6. After the gate interval completes, read 38 bytes starting at 0x48.

Expected count behavior:

If oscillator frequency is 11 MHz and gate time is 1 ms:

Count ≈ 11,000

7. To test DAC:
   - Write DAC codes to 0x12–0x15
   - Write 0x26 = 0x02 to commit
   - Observe SPI transaction

8. To test ADC:
   - Provide known SPI data pattern
   - Confirm value appears in registers 0x34–0x35 and snapshot stream

## External hardware

Required:
- 50 MHz clock source
- I²C master (microcontroller or FPGA)
- Up to 9 oscillator sources
- External SPI DAC (2-channel)
- External SPI ADC (12-bit, ADS7042-style compatible)

Optional:
- Resonant sensors (QCM, FBAR, SAW, etc.)
- Temperature sensor connected to ADC
- Bias control circuitry driven by DAC outputs
