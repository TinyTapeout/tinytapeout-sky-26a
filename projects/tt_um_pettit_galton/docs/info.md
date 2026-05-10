
## How it works

This is a VGA Demo that draws a Galton peg board and "drops" soft paint balls (they "squish" at the bottom) onto the pegboard.  
It supports the gamepad PMOD and also has audio output when the balls hit the pegs if the Audio PMOD is connected (output on uio_out[7]).

It uses three prime LFSR sequences with a single bit from each XOR'ed together to create a random "left/right" decision per peg that the 
falling ball encounters.  When it exits the bottom of the playing field, it will hit the bottom and "pop" or flatten out.  This will form
a historgram of where the balls land most.  Each bin counts up to 64 "balls".  When it gets full, it changes color and then begins showing
the number of times it has filled up.  So the actual number will be the number displayed times 64 (plus whatever extra is in the grey
bar).

![](galton_frame.png)

## How to test

Connect the VGA Pmod and watch as the balls come tumbling down.  Optionally connect audio PMOD to hear sounds effects as the balls bounce
off the pegs in the Galton board.

If you connect a gamepad PMOD, you can us the following buttons:

A:     Hold the ball at the top of the board prior to releaseing (this will also add randomization, not that it is really needed)
Left:  You can coerce the topmost two left/right decisions to go left
Right: You can coerce the topmost two left/right decisions to go right
Up:    Increase the ball drop speed.  It can get pretty fast.
Down:  Reduce the ball drop speed.
Start: When the board fills (i.e. when one of the bins receives 958 balls) start will reset for it to begin again.

When no gamepad PMOD is connected, the speed is constant and if it ever fills (would take a long time), it will reset automaically.

## External hardware

VGA Pmod.
Optional gamepad PMOD.
Optional Audio PMOD (output is on uio_out[7]
