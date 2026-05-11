<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The system is a digital locking circuit that checks a 4-bit input (A, B, C, D). It uses basic logic gates to compare the input against a fixed password.

The correct password is 1010, and the logic implemented is:

E = A · B' · C · D'

This means:

A and C must be HIGH (1)
B and D must be LOW (0), enforced using NOT gates

All four conditions are combined using AND gates. Only when all conditions are satisfied does the output (E) become HIGH, which turns on the display (showing “U” for unlocked).

Additionally, a latch is used to implement a permanent lock condition. If the input 1111 is entered, the latch is triggered and forces the system into a locked state. After this, even entering the correct password will not unlock the system.

## How to test
Set the inputs A, B, C, and D using switches.
Try different combinations:
Enter 1010 → the system should unlock (display turns on)
Enter any other combination → the system should remain locked
Test the special condition:
Enter 1111 → system enters permanent lock
After this, try entering 1010 again → it should NOT unlock

This confirms both the password logic and the latch behavior are working correctly.

## External hardware
4 input switches (for A, B, C, D)
Logic gates (AND, NOT, NAND as required)
SR latch (for permanent lock condition)
7-segment display (to show “U” when unlocked)
LED or output indicator (optional, for debugging)
