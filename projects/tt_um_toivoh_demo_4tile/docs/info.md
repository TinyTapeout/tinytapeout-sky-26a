<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## Intro

Curly / Medieval presents **Underflow Cubed**,
my contribution to the four tile category of the TTSKY26a demo competition.
Code, graphics, and music by Curly (Toivo Henningsson) of Medieval.

The demo can be seen at https://youtu.be/m0GFAU291TQ (captured from a Verilator simulation).

## How it works

The 3d scenes use a custom per scan line rendering algorithm derived from a ray tracing formulation, but sharing computations between different pixels in the same scan line when possible.
Much more details can be found at https://possible-realities.blogspot.com/2026/05/tracing-beam.html.

The synth works in a quite similar way to the one described in https://github.com/toivoh/tt10-demo/blob/main/docs/info.md.
Many of those ideas are described further in https://github.com/toivoh/ttsky25a-pwl-synth/blob/main/docs/info.md, but that synth uses a phase accumulator per voice, instead of calculating voice phases from a shared oscillator.
The synth is sampled at 63 kHz at almost 10 bit resolution (PWM output from 0 to 800), with delta-sigma modulation to add 4 additional bits of resolution.
The synth has 24 voices, which are evaluated in turn to calculate each sample. One voice is evaluated in 32 cycles.
To support the greater number of voices (Orion Iron Ion supported 12), a faster multiplication algorithm is used to calculate the phase from the global oscillator using a radix 4 Booth multiplier.
Most notes use 4 voices with slightly different detuning (and two different octaves for the organ patch), with 2 voices per note for the chords.

The sequencer puts together the note material from a few different sources:

- the main melody,
- the current chord for the main melody (root note, sus4 or not, fourth note: nothing / 7 chord / double the root on octave up)
- patterns for the bass and accompaniment based on the current chord

All notes except the melody are derived from the curent chord.

Notes are expressed a scale of 7 notes per octave. These are translated to actual pitches using the current key, which can switch between

- A harmonic minor
- C harmonic minor
- C minor
- C dorian
- C mixolydian
- C major

When modulating at the end of many sections, the melody note is initially kept in the current key, while the rest of the notes go to the new key.

While the synth evaluates a new voice every 32 cycles, actually only 23 of those cycles are needed.
The `speedup` option exploits this by letting the user skip some or all of the 9 unused cycles per voice. This will be useful if it turns out that the silicon is too slow to work at the intended 50.4 MHz clock frequency.
Normally, the raster scan generator for VGA spends two cycles per pixel, but when skipping a cycle that is unused by the synth, the corresponding VGA pixel gets only one cycle.
Since the length of the horizontal front porch, active area, back porch, and horizontal sync are all multiples of 16 pixels, skipping cycles like this doesn't alter the relative length of these intervals.

Skipping cycles using the `speedup` option reduces the resolution of the PWM output, which can eventually lead to some clipping.
It also gives the rendering algorithm fewer cycles to compute the pixels for the current scan line, increasing the amount of visual artifacts.

## How to test

Plug in a [TinyVGA](https://github.com/mole99/tiny-vga) compatible Pmod on the demo board's out Pmod.
Plug in a Pmod compatible with [Mike's audio Pmod](https://github.com/MichaelBell/tt-audio-pmod) on the TT08 demo board's bidir Pmod.
Set all inputs to zero to get the default behavior.
The demo starts directly after reset.

### Options

With `interlace_disable=0` (the default), the demo offsets the camera motion between even and odd scan lines. This makes the motion smoother, but edges become more jagged.
With `interlace_disable=1`, edges become less jagged, but in many sections, the image only updates every other frame, causing an apparent frame rate of 30 fps instead of 60.

The 3-bit `speedup` input lets you run the demo at slower clock frequencies and still output a 640x480 @ 60 fps VGA signal, at the cost of more visual artifacts.
The recommended clock frequency is

	(50.4 MHz) * (32 - speedup[1:0]*2 - speedup[2]*3)

that is

	speedup   clock frequency
	0         50400000 Hz
	1         47250000 Hz
	2         44100000 Hz
	3         40950000 Hz
	4         45675000 Hz
	5         42525000 Hz
	6         39375000 Hz
	7         36225000 Hz

The `advance_x` and `advance_y` inputs are used for testing in GL simulation, and should normally be kept at 0. They cause the demo to skip ahead, and interfere with the VGA timing.

## External hardware

This project needs
-  a [TinyVGA](https://github.com/mole99/tiny-vga) VGA Pmod.
- [Mike's audio Pmod](https://github.com/MichaelBell/tt-audio-pmod).
