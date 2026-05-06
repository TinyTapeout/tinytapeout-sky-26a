<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project uses the VGA PMOD to generate video and the GamePad PMOD to provide player control, only single control is supported.

There's a set of 3 missiles and 4 bombs existing and paint only according to the game dynamics, that is, missiles paint only when the game activate 1, 2 or 3, the explosions show when the user presses button A and can fire 1-4 simultaneous explosions.

The game starts at level 0 with maximum missiles movement delay, each level comprises at least 10 missiles in waves of 1, 2, or 3, the missiles direction is mostly targeting the fortress. If the fortress receives 3 impacts in the same level the game ends, the impacts resets on every level change.

The circuit relies on several modules that generate video bits for particular images based either on formulas or predefined data matrixes, then, according to the coordinates x and y of the sync generator (current pixel position) and the position defined for the image/sprite it outputs video data. The top level module multiplexes the video signals to output either the currenyly active module or the blue background. The following modules generate game components:

- Corsshair: paints the cross that represent game cursor to indicate where an explossion will occur, is manually moved by the player.
- Explosion: a formula-based image/sprite that paints a growing/shrinking square from 4x4 to 48x48 in white representing an anti-aereal bomb defense explosion.
- Fortress: represents the "life" of the player, it is the main target of the incoming missiles waves, supports up to 3 hits per level and the game ends if during the same level it receives the 3 missile hits.
- Game Over Banner: a matrix-based sprite that shows the "GAME OVER" message in red color when the player loses.
- Level Banner: a matrix-based sprite that shows the "LEVEL N" message on the top left of the screen indicating the current level with a number from 0 to 9.
- Missile Starter: a pesudo-random generator for missile starting point indicating also the direction in the x axis so missiles mostly head towards the fortress.
- Missile: draws the line representing the trajectory of a missile in flight in yellow, also, detects colission with explosion and/or fortress based on current pixel colors.
- Start Banner: a matrix-based sprite that shows the "PRESS START" when the game resets or after the game ends to indicate the user how to begin playing.

The priority is: Explosions (back most), missiles, fortress, level banne and crosshair (front most) when the game is active, the game over and start banner show only when the game isn't active.

## How to test

Just connect the PMODs to the TT Dev kit voard, then connect the monitor and the controller to the corresponding PMODs and play!

## External hardware

- TinyTapeout dev kit (the version corresponding to TTSky26a)
- [VGA PMOD](https://store.tinytapeout.com/products/Tiny-VGA-Pmod-p678647356)
- [GamePad PMOD](https://store.tinytapeout.com/products/Gamepad-Pmod-p741891425)
- Monitor supporting 640x480@60 with the respective male cable
- SNES controller
