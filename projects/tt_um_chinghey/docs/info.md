# Hey FlexCompute-130

## How it works

The **Hey FlexCompute-130** is a hybrid computational accelerator designed for the Tiny Tapeout 1x1 tile. It combines two powerful mathematical engines in a single design: a resource-optimized **INT8 Neural Processing Unit (NPU)** and a **12-bit CORDIC Processor**.

### 1. NPU Core (Sequential MAC)
To fit within the strict ~1,000 gate limit, the NPU uses a **Folded MAC Architecture**.
- **Sequential Multiplier:** Replaced the area-heavy combinational multiplier with an 8-cycle shift-and-add unit.
- **Signed Arithmetic:** Full 2's complement support for both weights and inputs.
- **SPI Weight Streaming:** Features a custom SPI receiver with CDC synchronization to stream weights from external memory.
- **Zero-Cost ReLU:** Integrated activation function directly in the output stage.

### 2. CORDIC Core (Trigonometric/Hyperbolic)
A bit-iterative hardware engine that computes complex functions using only shifts and additions.
- **12-bit Precision:** Uses a `Q2.10` fixed-point format (1 sign, 1 integer, 10 fractional bits).
- **Versatile Modes:** 
  - **Circular:** Computes Sine and Cosine.
  - **Hyperbolic:** Computes Sinh and Cosh (includes the $i=4, 13 \dots$ iteration repeats for convergence).
  - **Vectoring:** Computes the Arctangent (Atan) of an input coordinate.
- **Pre-computed LUT:** Uses a high-precision `atan_lut` for rotation angles.

---

## How to test

The chip's behavior is controlled by the **Mode Pins** (`uio[7:6]`).

### Pin Mapping Overview
| Pin | Function | Mode dependency |
| :--- | :--- | :--- |
| **`uio[7:6]`** | **Mode Select** | 00=NPU, 01=Circular, 10=Hyperbolic, 11=Atan |
| **`uio[4]`** | **Byte Select** | 0=Output Low Byte [7:0], 1=Output High Byte [15:8] |
| **`uio[3]`** | **Selector / Reset** | NPU: Clear Acc. CORDIC: 0=X (Cos), 1=Y (Sin) |
| **`uio[5]`** | **Done Pulse** | Pulses high when a calculation is finished |

---

### Testing the NPU (Mode 00)
1. **Clear**: Pulse `uio[3]` high to reset the accumulator.
2. **Input**: Provide an 8-bit feature on `ui_in`.
3. **Weight**: Stream an 8-bit weight via SPI (`uio[0]=SCLK, uio[1]=MOSI, uio[2]=CS`).
4. **Read**: Toggle `uio[4]` to read the 16-bit result from `uo_out`.

### Testing CORDIC (Modes 01, 10, 11)
1. **Mode**: Set `uio[7:6]` to `01` (Sin/Cos) or `10` (Sinh/Cosh).
2. **Input**: Provide the angle $\theta$ on `ui_in` (Scale: $1.0 \text{ rad} \approx 128$ in decimal).
3. **Wait**: Wait for the `uio[5]` pulse (approx 12-15 cycles).
4. **Select Result**: 
   - Set `uio[3] = 0` for Cosine / Cosh.
   - Set `uio[3] = 1` for Sine / Sinh.
5. **Read**: Use `uio[4]` to read the 16-bit result in two bytes.

---

## IO Connections

| Port | Pin | Name | Description |
| :--- | :--- | :--- | :--- |
| **Input** | `ui[7:0]` | `data_in` | 8-bit Data/Angle Input |
| **Output**| `uo[7:0]` | `acc_out` | 8-bit Multiplexed Output |
| **Bidirectional** | `uio[0]` | `sclk` | SPI Clock |
| | `uio[1]` | `mosi` | SPI Data |
| | `uio[2]` | `cs` | SPI Chip Select |
| | `uio[3]` | `ctrl` | Reset Acc / Function Select |
| | `uio[4]` | `sel` | Byte Selector (Low/High) |
| | `uio[5]` | `done` | Done Flag |
| | `uio[7:6]`| `mode` | Mode Selection |
