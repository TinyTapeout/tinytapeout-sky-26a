<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.

Helped by AI ^^

BR,
Dat Dinh Trong
-->

## Purpose

Bubble Sort Engine is a hardware macro that sorts an array of 8-bit elements using the Bubble Sort algorithm. Instead of software-based sorting, this module accelerates the process by running it directly in hardware, supporting up to 8 elements with handshaking. It is designed to optimize sorting operations with low latency based on data streaming.

## Register Map / I/O Map

The design does not use a traditional Register Map addressable interface. Instead, it communicates directly via configured pins using a Data Stream model with Valid/Ready signals:

- **Data Inputs (`ui_in[7:0]`)**: Contains the input value (`in_data[7:0]`) to feed into the sorter.
- **Data Outputs (`uo_out[7:0]`)**: Contains the output value (`out_data[7:0]`) in ascending sorted order.
- **Control Pins (`uio_in` / `uio_out`)**:
  - `uio_in[0] - start`: A start pulse to reset the hardware and prepare it to receive data.
  - `uio_in[1] - in_valid`: Master indicates that the current `in_data` on the bus is valid.
  - `uio_in[2] - in_last`: Indicates that the currently pushed element is the last element of the array.
  - `uio_in[3] - out_ready`: External Master indicates it is ready to receive output results.
  - `uio_out[4] - in_ready`: Engine indicates it is ready to receive new data from the Master.
  - `uio_out[5] - out_valid`: Engine indicates the data present on the `out_data` port is valid.
  - `uio_out[6] - out_last`: Engine indicates the current output element is the largest/last element of the array.

## Usage

1. **Start Phase**: Issue a single pulse on `uio_in[0]` (`start = 1`) to reset the module to IDLE mode and make it ready to receive inputs (`uio_out[4]` / `in_ready = 1`).
2. **Input Phase**: 
   - Drive the 8-bit data into the `ui_in[7:0]` (`in_data`) pins.
   - Set `uio_in[1]` (`in_valid = 1`). Whenever both `uio_in[1]` (`in_valid`) and `uio_out[4]` (`in_ready`) are 1 at the rising edge of the clock, the data is latched internally.
   - When transmitting the last element of the array (maximum length 8), assert `uio_in[2]` (`in_last = 1`) concurrently with `uio_in[1]` (`in_valid = 1`).
3. **Sort Phase**: After receiving the last element, the module automatically runs the internal Bubble Sort algorithm. This phase executes automatically over multiple clock cycles.
4. **Output Phase**: Once sorting is completed, the circuit asserts `uio_out[5]` (`out_valid = 1`). The External Master must assert `uio_in[3]` (`out_ready = 1`) to read each element continuously from the `uo_out[7:0]` (`out_data`) pins. The signal on `uio_out[6]` (`out_last = 1`) notifies the Master that the entire sorted array has been successfully streamed out and the Engine will return to the `IDLE` state.

## How to test

This project employs two approaches to ensure reliability in the digital design:

### 1. Testbench Simulation (TB & Cocotb)
The module is set up with a testbench powered by the `cocotb` framework. You can use the `test/test.py` script alongside Icarus Verilog (`iverilog`) by running the `make` command inside the `test/` directory. 
The testbench automatically loads various array test suites and manipulates the Valid/Ready flags. It meticulously uses the `ReadOnly()` phase to capture synchronous data correctly and perform assert checks against the Python software equivalent, identifying edge cases related to latency.

### 2. Formal Verification
The system mathematics and edge cases are formally verified using the Cadence/Siemens **Jasper** Formal Verification tool. 
Since testbench coverage cannot guarantee 100% bug elimination, Formal Verification ensures absolute handshaking logic in the State Machine, boundaries on memories and counters (`count`, `out_ptr`), and mathematically proves the design avoids deadlocks and invalid states via SVA (SystemVerilog Assertions).

## Bubble Sort Time Complexity

### Bubble sort has the following time complexities:

- **Worst-case time complexity:**  
  $O(n^2)$

- **Average-case time complexity:**  
  $O(n^2)$

- **Best-case time complexity (with swap flag optimization):**  
  $O(n)$

## External hardware

All built-in, we are all in-house, no need to outsource, because we are strong enough
