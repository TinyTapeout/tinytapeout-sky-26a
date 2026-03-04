<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

AND are connected to input c and b ,  NOT is connected to input a, OR gates are connected to input b and c.

## How to test

Set the inputs and check the outputs match with the expected results:

| Input a | input b | input c | output AND | output NOT | output OR |
0          0          0        0            1              0
0          0          1        0            1              1
0          1          0        0            1              1
0          1          1        1            1              1
1          0          0        0            0              0
1          0          1        0            0              1
1          1          0        0            0              1  
1          1          1        1            0              1

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
