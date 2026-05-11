<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
# AXI4-Lite Top Project

##  Overview
This project implements a **self-contained AXI4-Lite system** with a master and a slave connected inside a top-level wrapper (`axi4lite_top`).  
It exposes a **simple control interface** so that reads and writes can be performed without directly driving AXI signals.  

---

##  How It Works
- The **top module** (`axi4lite_top`) instantiates:
  - An **AXI4-Lite Master**  
  - An **AXI4-Lite Slave**  
- Instead of requiring the user to control all AXI signals, the top module provides a simplified interface:
  - `ui_in[0]` → Start Write  
  - `ui_in[2:1]` → Write Address  
  - `uio_in` → Write Data  
  - `ui_in[4]` → Start Read  
  - `ui_in[3:2]` → Read Address  
- When a transaction is started:
  - The master drives the appropriate AXI4-Lite signals.  
  - The slave responds according to AXI protocol.  
  - When the transaction finishes, `uo_out[0]` goes high (Done).  
  - On reads, the data is returned via `uio_out`.  

Effectively, this module **hides AXI4-Lite complexity** and lets the user test simple memory-mapped transactions.  

---

##  How to Test
Two types of testbenches are provided:

### 1. Verilog Testbench
- Located at `sim/axi4lite_tb.v`.  
- Runs a reset → write → read → check sequence.  
- Displays results in the simulator console.

### 2. Cocotb Testbench
- Located at `sim/test_axi4lite.py`.  
- Uses Python for more flexible verification.  
- Run with Icarus Verilog:
  ```bash
  make SIM=icarus TOPLEVEL=axi4lite_top MODULE=test_axi4lite
