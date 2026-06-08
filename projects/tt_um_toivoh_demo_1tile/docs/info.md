<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## Intro

Curly / Medieval presents **Underflow Uncubed**,
my contribution to the single tile category of the TTSKY26a demo competition.
Code, graphics, and music by Curly (Toivo Henningsson) of Medieval.

The demo can be seen at https://youtu.be/JkifIYlgSE0 (captured from a Verilator simulation).

The demo contains the same music as my four tile demo [Underflow Cubed](https://github.com/toivoh/tt26-demo-4tile), but the 3d graphics did not fit in the single tile format.
I was able to add a music visualizer, though.

## How it works

The synth works in a quite similar way to the one described in https://github.com/toivoh/tt10-demo/blob/main/docs/info.md.
Many of those ideas are described further in https://github.com/toivoh/ttsky25a-pwl-synth/blob/main/docs/info.md, but that synth uses a phase accumulator per voice, instead of calculating voice phases from a shared oscillator.

The synth computes a new sample every 800 cycles; twice per scan line.
One sample every scan line is used for sound output, and the other is used for visualization.
The difference between these samples is which value is used for the shared oscillator phase. For the sound output, it is free-running, while it is based on the current y position for the visualization.
The result is that the synth is sampled at 31.5 kHz. The ouput resolution is almost 10 bits (PWM output from 0 to 800), with delta-sigma modulation to add 4 additional bits of resolution.

The synth has 24 voices, which are evaluated in turn to calculate each sample. One voice is evaluated in 32 cycles.
Each voice is displayed on screen starting from when it has just been computed until when the next voice has been computed, 16 pixels in total (2 cycles/pixel).
To support the greater number of voices (Orion Iron Ion supported 12), a faster multiplication algorithm is used to calculate the phase from the global oscillator using a radix 4 Booth multiplier.
Most notes use 4 voices with slightly different detuning (and two different octaves for the organ patch), with 2 voices per note for the chords.

The palette changes use a simplified version of the corresponding code in the four tile version.

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

## How to test

Plug in a [TinyVGA](https://github.com/mole99/tiny-vga) compatible Pmod on the demo board's out Pmod.
Plug in a Pmod compatible with [Mike's audio Pmod](https://github.com/MichaelBell/tt-audio-pmod) on the TT08 demo board's bidir Pmod.
Set all inputs to zero to get the default behavior.
The demo starts directly after reset.

### Options

By default, the demo uses half of the samples for visualization, and half for sound output, which results in a sample rate of 31.5 kHz.
By setting `use_full_sample_rate = 1`, the sample rate is doubled to 63 kHz. Please note that this causes the visualization to use the raw audio output for each channel, which can result in a lot of flickering!

The 3 bit `scale_override` input can be used to overide the scale used to play the music. By default, the scale varies over time.

	scale_override   scale/key

	0                default
	1                A harmonic minor
	2                C minor
	3                
	4                C harmonic minor
	5                C dorian
	6                C mixolydian
	7                C major

The 3-bit `speedup` input lets you run the demo at slower clock frequencies and still output a 640x480 @ 60 fps VGA signal. This should hopefully not be needed, especially not in the 1-tile-version.
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

The `advance_y` input is used for testing in GL simulation, and should normally be kept at 0. It causes the demo to skip ahead, and interferes with the VGA timing.

## External hardware

This project needs
-  a [TinyVGA](https://github.com/mole99/tiny-vga) VGA Pmod.
- [Mike's audio Pmod](https://github.com/MichaelBell/tt-audio-pmod).
