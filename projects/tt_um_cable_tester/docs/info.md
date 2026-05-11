## How it works

This is an 8-wire DC continuity tester for Ethernet (and any other 8-conductor) cable.
The 8 bidirectional `uio` pins each connect to one wire of an RJ45 jack on the test
board. On the *far* end of the cable under test, all 8 wires are tied together at a
single common node (a soldered-together RJ45 plug — described below).

After reset the chip runs forever, on a continuous loop:

1. Drive `uio[k]` high while all other `uio` pins are high-Z inputs.
2. Wait `2^SETTLE_BITS` clock cycles so the cable's RC time constant can settle.
3. Sample all 8 input pins. For every bit `j != k` that read high, set bit `j` of
   an internal accumulator.
4. Advance `k`; after `k` reaches 7, copy the accumulator into the visible output
   register, clear the accumulator, and start the next pass.

In steady state, `uo_out[j] = 1` iff some other intact wire saw wire `j` light up
during that other wire's drive cycle. Because the far end shorts all wires together,
this happens exactly when wire `j` is electrically continuous from the near-end RJ45
to the far-end common node.

For the fabricated build, `SETTLE_BITS = 13` (8192 cycles per pin, ≈ 2.6 ms per
full pass at 25 MHz). Simulation builds with `-DSIM_FAST` shrink this to 3 bits.

### Limitation

If only one wire in the entire cable is intact, it has no partner to confirm
against and will be reported as bad. Cables with seven or more broken wires fail
the same way for this and every other reason.

The tester also does not detect:

* **Split pairs** (correct DC continuity, wrong twisted-pair routing). Those are
  AC-only faults — a real time-domain reflectometer is needed.
* Cable **length**, impedance, return loss, NEXT, or shielding integrity.
* Wire-to-wire **swaps** at the connector (e.g. T568A vs T568B miswiring). The
  far-end common node hides any swap.

## How to test

You need two pieces of hardware:

**Far-end shorting plug:** an RJ45 male connector with all 8 contacts soldered
together into a single node. No resistors, no diodes, no PCB. The simplest version
is a piece of stranded wire crimped into a spare RJ45 plug.

**Near-end test board:** routes the 8 cable wires to `uio[0..7]`, with on-board
LEDs on `uo[0..7]` and per-line protection. See *External hardware* below.

Once both are built:

1. Plug the shorting plug onto one end of the cable under test.
2. Plug the other end into the tester board's RJ45 jack.
3. Apply power.

After ~one display-update period (a few milliseconds at the fab clock), each of
the 8 `uo` LEDs reflects the state of the corresponding wire:

* All 8 LEDs on → the cable is good.
* Any LED off → that specific wire is open. The LED bit number `k` corresponds
  to RJ45 pin `k+1`.

The chip retests continuously, so you can wiggle the cable and watch LEDs flicker
to find intermittent faults.

## External hardware

For each `uio[k]` line, between the chip pin and the RJ45 jack:

* **220 Ω** series resistor (current limit + light ESD softening).
* **100 kΩ** pull-down to GND (defines logic 0 when the wire is open).
* **TVS diode array** to GND across the 8 lines (e.g. SP0524). Ethernet jacks
  attract static; without TVS the chip will not survive routine cable swaps.

For each `uo[k]` line: an LED with a series resistor (~1 kΩ for typical LEDs)
to GND.

No magnetics, no PHY ICs — this is a DC test, not an Ethernet PHY.

**Far-end dongle:** a single RJ45 male plug with all 8 contacts shorted to one
node. Zero electronic parts.
