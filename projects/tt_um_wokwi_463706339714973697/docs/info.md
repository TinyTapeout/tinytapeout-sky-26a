<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project re-implements a 74181 4-bit ALU, but with input coming from programmable (2-bit and)
4-bit registers - both to handle being constrained on input pins and to demonstrate working with registers.
(The project deliberately does not use bidirectional pins.)

## How to test

From an educational perspective, this circuit is interesting since
it features both programmable registers and an ALU. Hence,
"we are already halfway to understanding how a basic CPU works".

Data Bus:

IN0 = d0
IN1 = d1
IN2 = d2
IN3 = d3

Control Code:
IN4 = q0
IN5 = q1
IN6 = q2

### Usage

* Control codes (q0,q1,q2) = (0,?,?) are "inert", 
  while control codes of the form (1,?,?) are used to "program"
  the internal registers CTRL, A, B, S. This scheme allows us to
  even observe and experiment with ALU behavior using input from
  DIP switches if the circuit runs at MHz+ frequencies.

* Both for the simulator (where we should use clock-circuit input)
  and a real ASIC implementation based on this design, we can use
  this protocol:

  * Set all inputs to 0.
 
  * Activate "Reset"

  * Set d0 to M and d1 to the input-carry C.
    If we want to perform arithmetic operations with no incoming carry,
    we want to set both to zero.

  * Set (q0,q1,q2) to 100 and wait until we crossed at least
    one rising clock edge. This loads the values 
    of d0 and d1 into the 2-bit register (M, C).
    (If we want to select "logic mode", or set an input-carry,
    we can do this by setting d0 and d1 differently.)

  * Set (q0,q1,q2) to 000. This de-activates "M/C programming mode" and "freezes" these values.

  * Set (d0,d1,d2,d3) to the value that is to go into register A.
 
  * Set (q0,q1,q2) to 001.
 
  * Set (q0,q1,q2) to 101 and wait until we crossed at least one rising clock edge (as above).
 
  * Set q0 to 0, to de-activate "register-A programming mode".
    
    Register A now retains the value we programmed into it.

  * Set (d0,d1,d2,d3) to the value that is to go into register B.

  * Set (q0,q1,q2) to 010.

  * Set (q0,q1,q2) to 110 and wait as above.

  * Set q0 to 0, to de-activate "register-B programming mode".

  * Set (d0,d1,d2,d3) to the value that is to go into the S-register to select the ALU operation.
  
    See table at
    https://en.wikipedia.org/wiki/74181#Function_table_for_output_F:
    e.g. 1001 sets the ALU to "compute A+B+carry" if we also select
    "arithmetic mode".

  * Set (q0,q1,q2) to 011.

  * Set (q0,q1,q2) to 111 and wait as above.

  * Set q0 to 0.
   
     The output pins should then show the result of the calculation.

## External hardware

Arbitrary - even wiring this up to DIP switches and using LEDs for output should work.
