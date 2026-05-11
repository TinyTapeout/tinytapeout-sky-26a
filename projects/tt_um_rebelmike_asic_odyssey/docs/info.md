<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

An LFSR starfield in the background, with a cellular automata "monolith" in the foreground, complete with TT logo "sticker" that comes from a ROM.  A 2001: A Space Odyssey inspired theme plays.

## How to test

Set inputs to 0, provide a 36MHz clock, reset.  There should be VGA video (800x600 @ ~56.35Hz) and PWM audio.

## External hardware

VGA PMOD, Audio PMOD
