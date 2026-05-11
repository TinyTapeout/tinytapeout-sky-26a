<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Uses an LFSR to generate two 8-bit pseudonrandom numbers that are used to decide the transitions on two Markov Chains, one for the duration of the note
and the other one for the note itself, then the logic control module uses two FSM to model the Markov Chains and indicate to the final module, a PWM generator, the target note.

## How to test

You have 6 inputs you can change however you want, four are for the last 4 bits of the seed of the LFSR, so you have up to 16 different melodies, and two other inputs that change
The dynamic of the melody, making it go faster (60 or 120 BPM), and the other affects the duration of the notes.

## External hardware

A PMOD of a buzzer is required.
