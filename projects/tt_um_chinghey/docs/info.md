<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a resource-optimized Neural Processing Unit (NPU) core designed for the Tiny Tapeout 1x1 tile (SKY130). To fit within the strict ~1,000 gate limit, the design uses a **Folded MAC Architecture** featuring a **Sequential Shift-and-Add Multiplier** instead of a standard combinational multiplier.

### Technical Highlights:
- **Area-Constrained Design:** Replaced the generic Verilog `*` operator (which consumes $O(N^2)$ area) with a sequential 8-cycle multiplier. This allows the NPU to support full **Signed INT8** precision while staying under the gate count budget.
- **Signed Arithmetic:** Implemented 2's complement multiplication with proper sign-extension and conditional subtraction for the multiplier's MSB.
- **SPI Weight Streaming:** Includes a custom SPI receiver designed to stream weights from external memory. It features **Clock Domain Crossing (CDC)** pulse synchronization to safely transfer the `done` signal from the SPI clock domain to the system clock.
- **Orchestrated FSM:** A 4-state Finite State Machine (`IDLE`, `FETCH`, `COMPUTE`, `DONE`) coordinates the data flow between SPI, the MAC core, and the accumulator.
- **Zero-Cost ReLU:** Integrated ReLU activation directly into the output stage of the 16-bit accumulator.

## How to test

The NPU computes $Y = ReLU( \sum (input_i \times weight_i) )$.

### Testing Workflow:
1. **Reset:** Assert `rst_n` low to initialize the FSM and clear the 16-bit accumulator.
2. **Data Input:** Provide an 8-bit input feature on `ui_in`.
3. **Weight Stream:** Send the 8-bit weight via the SPI interface (`uio[0]=SCLK`, `uio[1]=MOSI`, `uio[2]=CS`). The NPU captures the weight and triggers the 8-cycle compute sequence automatically.
4. **Accumulate:** Repeat for multiple weight/input pairs. The internal register accumulates the partial sums.
5. **Read Result:** The 16-bit result is multiplexed on `uo_out`.
   - Set `ui_in[0] = 0` to read the Low Byte.
   - Set `ui_in[0] = 1` to read the High Byte.
6. **End of Layer:** Set `ui_in[7] = 1` to trigger the `DONE` state, which pulses a "complete" signal on `uio[7]` and resets the accumulator for the next calculation.

## External hardware

- **SPI Source:** An external RP2040 microcontroller or SPI Flash RAM to provide weight coefficients.
- **Input Driver:** Parallel 8-bit data source for input features.
