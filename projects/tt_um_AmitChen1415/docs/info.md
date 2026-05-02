<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
 
The project is a simplified Blackjack game implemented entirely in digital hardware.
The core game logic (cards, rules and balance) runs as a finite-state machine, and a
16-bit LFSR is used as a pseudo-random card generator.
The player interacts with the game using push-buttons (Hit / Stand / Double / Start),
and the internal state can be visualized via a VGA “blackjack table” screen.
All logic is fully synthesizable and fits into a single TinyTapeout tile.

Short description of the modules involved:

## tt_um_AmitChen1415.v
Top module of the project. Connects all sub-modules and maps the TinyTapeout
I/O pins to the internal signals.
ui_in bits are used as the player buttons (Start / Hit / Stand / Double), and
uo_out is currently wired to the VGA signals for visual debugging.
Instantiates the blackjack_core game engine and the reset-synchronizer.

## blackjack_core.v
Heart of the design – implements the Blackjack rules as a finite state machine.
Handles the full round flow: initial deal (2 cards to player, 1 to dealer), player
actions (Hit / Stand / Double), dealer drawing until 17, and final result
computation.
Maintains the player and dealer totals, checks for bust / win / push, detects a
natural blackjack, and updates the chip balance accordingly.
Uses the card RNG to draw new card values.

## rng_card.v
Small wrapper around the 16-bit LFSR that converts its raw random value into a
valid card value in the range 2–11 (2–10 and Ace=11).
Used by blackjack_core whenever a new card needs to be dealt.

## lfsr16.v
16-bit Linear Feedback Shift Register used as a pseudo-random number generator.
Can be reset to a default non-zero state or loaded with a custom seed.
Provides a deterministic but “random-looking” sequence suitable for the game’s
card draws.

## pwrup_synchronizer.v
Two-flip-flop synchronizer for the active-low reset.
Ensures that the reset signal is safely synchronized to the internal clock
before releasing the rest of the logic from reset, avoiding metastability at
power-up.

## vga_controller.v
Generates the standard 640×480@60Hz VGA timing: horizontal/vertical counters,
hsync and vsync pulses.
Provides the current pixel coordinates (x, y) that are used by the graphics
module to decide which color each pixel should be.

## blackjack_table.v
Pixel-generator for the VGA output. Uses the (x, y) coordinates from
vga_controller to draw a green felt background, the dealer and player cards,
the “BLACKJACK” title in the center, a “BALANCE: $1100” label on the left, and a
face-down card deck on the right.
Implements a small 5×7 font and simple shapes (rectangles, borders, checker
patterns) to render the table layout.

## How to test

Connect the external hardware according to the specified pinout to play the Blackjack game.
The system tracks the dealer and player hands, calculating totals in real-time.
Use the designated hardware keys to Hit (request a card), Stand (end your turn),Double or Reset the game.

Once the hardware is connected, test the following sequence:

**Starting a New Round:** After a win or a loss, press the Start/Reset button (ui_in[4]). This action transitions the game state to the next round, clearing the previous hands and dealing a new set of cards.

**Doubling Down:** During the player's turn, press the Double Bet button (ui_in[2]).

Expected Logic: The current bet is doubled (shifting the potential outcome from $\pm50$ to $\pm100$). The player will automatically receive exactly one additional card, and the turn will immediately pass to the dealer.

**Gameplay Actions:** Verify that Hit (ui_in[0]) adds a card and Stand (ui_in[1]) ends the player's turn manually.

The goal is to achieve a hand value closer to 21 than the dealer without going over.

**Hardware Synchronization**

When performing a test or initializing the system, ensure the PLL (Phase-Locked Loop) is correctly tuned. This step is critical to align the internal clock frequency with the FPGA, ensuring stable data transmission and synchronized game logic across the hardware interface.

## External hardware

4 Keys (buttons) are required for game interaction:

1) Start/Reset
2) Hit
3) Stand
4) Double Bet

Additionally, a VGA module is required to connect the FPGA board to an external display.

**Connecting the Keys**

Place 4 push-button switches on a breadboard. For each key, follow the pinout specified below:

Hit (Request Card) -> ui_in [0]

Stand (End Turn) -> ui_in [1]

Double Bet -> ui_in[2]

Start / New Game -> ui_in[4]

## Display Setup

Interface a standard VGA module with the assigned output pins to enable the game's visual output. Ensure the module is securely seated to maintain signal integrity for the display.

![FPGA](https://github.com/user-attachments/assets/f1cee303-4e7a-4fbe-99d4-70eb974e1777)

