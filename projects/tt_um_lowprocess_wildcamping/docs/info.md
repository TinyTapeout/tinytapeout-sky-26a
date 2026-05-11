<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Structures currently implemented:
- 3/4 Modulus Prescaler with inverter
- Custom picoMIPS CPU from an old University Project
    - 24-bit program word
    - 4-bit (16 word) code memory
    - 16x8-bit register file
    - PC with relative jump and subroutine return
    - ALU with Addition / Subtraction / Multiply and Logical Operations, plus immediate ops.
- Shift register to feed instructions, Latches word on deselect if 24-bits have been shifted, generates clock for CPU.

## How to test

Input 0 / PRESC_D43 controls the division factor of a clock prescaler, and Output 0 will either be CLK/4 or CLK/3 to be verified using an Oscilloscope. Input 1 will invert the output of the prescaler.

Input 2 / SR_SCK, Input 3 / SR_SDI, Input 4 / SR_SCS, operate the Shift register. It is 24-bits wide, data is latched when chip select is relased.

When PICO_WFI[2] is high, the CPU is halted for input, which should be provided via Bidirectional Pins (PICO_UIO[6] should be high), Input 5 / PICO_INT should be held high. Clock 24-bits into the shift register to continue operation.

PICO_ADDR[4:0] represent the current requested address from the CPU.

PICO_HALT will go high if there is an unrecognised instruction.

SR_TEST can be used to validate operation of the shift register, the bottom 8-bits will appear once the output is latched (24-bits + CS released).

If the processor encounters an unknown instruction, it will halt and PICO_HALT will go high. NRST should be used to recover from a halt.

See Common.sv for the instruction set. You can use //https://hlorenzi.github.io/customasm/web/ as an assembler.

## External hardware

- Oscilloscope 

pinout:
  # Inputs
  ui[0]: "PRESC_D43"
  ui[1]: "PRESC_INV"
  ui[2]: "SR_SCK"
  ui[3]: "SR_SDI"
  ui[4]: "SR_SCS"
  ui[5]: "PICO_INT"
  ui[6]: "PICO_UIO"
  ui[7]: "SR_TEST"

  # Outputs
  uo[0]: "PRESC_OUT"
  uo[1]: "PICO_HALT"
  uo[2]: "PICO_WFI"
  uo[3]: "PICO_ADDR[0]"
  uo[4]: "PICO_ADDR[1]"
  uo[5]: "PICO_ADDR[2]"
  uo[6]: "PICO_ADDR[3]"
  uo[7]: "PICO_ADDR[4]"

  # Bidirectional pins
  uio[0]: "PICO_I/O[0]/SRT[0]"
  uio[1]: "PICO_I/O[1]/SRT[1]"
  uio[2]: "PICO_I/O[2]/SRT[2]"
  uio[3]: "PICO_I/O[3]/SRT[3]"
  uio[4]: "PICO_I/O[4]/SRT[4]"
  uio[5]: "PICO_I/O[5]/SRT[5]"
  uio[6]: "PICO_I/O[6]/SRT[6]"
  uio[7]: "PICO_I/O[7]/SRT[7]"
