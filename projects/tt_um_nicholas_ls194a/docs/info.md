## How it works

This design implements the behaviour of a TI **SN74LS194A**-style **4-bit bidirectional universal shift register**.

- Clocked on **rising edge** of `clk`
- **Asynchronous active-low clear** using TinyTapeout `rst_n`
- Mode select via `S1,S0`:
  - `00`: Hold (no change)
  - `01`: Shift right: `QA<-SR`, `QB<-QA`, `QC<-QB`, `QD<-QC`
  - `10`: Shift left:  `QD<-SL`, `QC<-QD`, `QB<-QC`, `QA<-QB`
  - `11`: Parallel load: `QA..QD <- A..D`

## How to test

1. Drive `rst_n = 0` briefly to clear all outputs to 0, then set `rst_n = 1`.
2. Set `S1,S0`:
   - Hold: `00`
   - Shift right: `01` (provide data on `SR_SER`)
   - Shift left: `10` (provide data on `SL_SER`)
   - Parallel load: `11` (set `A..D` then clock once)
3. Toggle `clk` and observe outputs `QA..QD`.

## External hardware

None required.
(Optionally: switches for inputs and LEDs for outputs on a TinyTapeout demo board.)
