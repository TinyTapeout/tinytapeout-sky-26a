<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a 4-bit comparator. It compares 2 binary numbers **A** and **B** using logic gates to determine if:

-A = B
-A > B
-A < B

The comparator checks the bits from the (Most significant bit) MSB to the (Least significant Bit) LSB. 
MSB         LSB MSB         LSB
IN0 IN1 IN2 IN3 IN4 IN5 IN6 IN7

The comparator controls the 7-segment display to show a letter representing the result of the comparison:
-If A=B, **E** for Equal displayed
-If A>B, **H** for High is displayed
-If A=B, **L** for Low is displayed

The display segments are controlled using OR logic gates so only one signal drives the display.

## How to test

Set the two 4-bit inputs (**A** and **B**) to different binary values and observe the 7-segment display output.

| A (4-bit)  | B (4-bit)  | Expected Result | Displayed Letter|
| IN0 to IN3 | IN4 to IN7 |                 |                 |
|------------|------------|-----------------|-----------------|
| 0000       | 0000       | A = B           | E               |
| 0011       | 0011       | A = B           | E               |
| 1000       | 0111       | A > B           | H               |
| 1111       | 0001       | A > B           | H               |
| 0010       | 0100       | A < B           | L               |
| 0001       | 1000       | A < B           | L               |


## External hardware

- **7-segment display** for output visualization
- Input switches or digital inputs for the two 4-bit values (**A** and **B**)

No additional external hardware is required.
