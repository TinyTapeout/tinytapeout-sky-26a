<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The ABC module is a **temporal coincidence detector**. On each rising clock edge (while `ena` is high) it samples two single-bit inputs — **X1** (`ui[0]`) and **X2** (`ui[1]`) — and classifies their relationship:

| X1 | X2 | A | B | C1 | C2 |
|----|----|---|---|----|----|
|  0 |  0 | 0 | 0 |  0 |  0 |
|  0 |  1 | 1 | 0 |  0 |  0 |
|  1 |  0 | 0 | 1 |  0 |  0 |
|  1 |  1 | 0 | 0 |  1 |  1 |

- **A** (`uo[0]`): pulses high when only X2 is high
- **B** (`uo[1]`): pulses high when only X1 is high
- **C1** (`uo[2]`) and **C2** (`uo[3]`): both pulse high when X1 and X2 are simultaneously high (coincidence)

All outputs are registered and update one clock cycle after the inputs are sampled. When `rst_n` is asserted low, all outputs are immediately cleared to zero. When `ena` is deasserted the outputs hold their last value.

## How to test

1. Assert reset (`rst_n` low) for at least one clock cycle — all outputs should read `0x00`.
2. Release reset and assert `ena`.
3. Drive `ui[0]` (X1) and `ui[1]` (X2) with the combinations in the truth table above and verify the corresponding outputs one clock cycle later.
4. Check that `uo[7:4]` is always `0`.
5. Deassert `ena` while changing inputs — outputs should hold their previous values.

## External hardware

None required.
