<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

SAP-1 CPU
- It is an accumulator based CPU that is purposely made very simple (hence the name, Simple As Possible) 
- I would've liked to added input but I thought I wouldn't have enough space on my tile for the extra hardware necessary - turns out I did but I didn't have enough time to implement it!
- Therefore the internal storage is ROM so it does run a program but you cannot change it

## How to test

Enable the project and reset to ensure initial state, LEDs should light up like this: 00001110, which is 14 in decimal

## External hardware

Eight LEDs on the output pins
