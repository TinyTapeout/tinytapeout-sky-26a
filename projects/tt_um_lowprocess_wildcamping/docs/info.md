<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Structures currently implemented:
- Inverter (Test Structure)
- 3/4 Modulus Prescaler
- Custom picoMIPS CPU from an old University Project
    - 24-bit program word
    - 4-bit (16 word) code memory
    - 32-bit register file
    - 8-bit data
    - PC with relative jump and subroutine return
    - ALU with Addition / Subtraction / Multiply and Logical Operations
    - Programmed with a 4-word 'Affine Transformation'
        - TODO: Reverse engineer how I actually did this.
        - TODO: Allow reprogramming via serial IF.

Structures still to be implemented:
- Accumulator with mux'd output bit
- 12-bit counter with compare register
- Serial interface
    - Code Modification

## How to test

Input 7 / INV_A is connected to Output 7 / INV_Y via an inverter, if this doesn't work there are bigger problems!

Input 0 / PRESC_43 controls the division factor of a clock prescaler, and Output 0 will either be CLK/4 or CLK/3 to be verified using an Oscilloscope.

Input 1 / PICO_INT sends an interrupt to the PICO CPU, which has an edge-trigger. The CPU can be instructed to wait until an interrupt is received. In this case Output 1 / PICO_WFI will go high.

If the processor encounters an unknown instruction, it will halt and PICO_HALT will go high. NRST should be used to recover from a halt.

## External hardware

- Oscilloscope 

pinout:
  # Inputs
  ui[0]: "PRESC_43"
  ui[1]: "PICO_INT"
  ui[2]: "PICO_I/O"
  ui[3]: ""
  ui[4]: ""
  ui[5]: ""
  ui[6]: ""
  ui[7]: "INV_A"

  # Outputs
  uo[0]: "DIV_CLK_43"
  uo[1]: "PICO_HALT"
  uo[2]: "PICO_WFI"
  uo[3]: ""
  uo[4]: ""
  uo[5]: ""
  uo[6]: ""
  uo[7]: "INV_Y"

  # Bidirectional pins
  uio[0]: "PICO_I/O[0]"
  uio[1]: "PICO_I/O[1]"
  uio[2]: "PICO_I/O[2]"
  uio[3]: "PICO_I/O[3]"
  uio[4]: "PICO_I/O[4]"
  uio[5]: "PICO_I/O[5]"
  uio[6]: "PICO_I/O[6]"
  uio[7]: "PICO_I/O[7]"
