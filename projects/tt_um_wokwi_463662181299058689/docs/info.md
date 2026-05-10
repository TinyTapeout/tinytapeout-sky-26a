<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
## How it works
A 2-bit ALU built from discrete logic gates — no microcontroller. Takes two 2-bit numbers (A and B) and a 2-bit opcode, computes all four operations in parallel (ADD, AND, OR, NOT A), then uses a 2-to-4 decoder and output selector to route the correct result to a 7-segment display showing digits 0–3.
## How to test
Set IN0–IN1 for input A, IN2–IN3 for input B, and IN4–IN5 for the operation (00=ADD, 01=AND, 10=OR, 11=NOT A). The 7-segment display shows the result. Toggle IN0 ON with everything else OFF — display should show 1. Toggle IN0 and IN2 ON — display should show 2.
External hardware
7-segment display on OUT0–OUT6. DIP switches on IN0–IN5.
