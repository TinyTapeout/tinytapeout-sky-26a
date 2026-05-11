# Bidirectional Command & Control Chronograph

## How it works

This design elevates a standard 1Hz digital stopwatch into an interactive, bidirectional hardware peripheral. It operates on a standard 10 MHz clock and integrates mixed-signal human interface handling with asynchronous serial communication. The architecture is divided into five core silicon modules:

1. **Hardware Debouncers:** Physical buttons are notoriously noisy. Inputs `ui_in[0]` and `ui_in[1]` are fed through 8-bit shift-register debouncers, ensuring a state change only triggers after 8 consecutive identical clock cycles, rendering switch-bounce physically impossible.
2. **The Core Chronograph & Shift-Memory:** A 24-bit clock divider generates a precise 1Hz pulse to drive a 4-bit BCD counter (0-9). Upon receiving a "Lap" pulse, the current BCD state is pushed into a 3-deep register memory array. The most recent lap is exposed to the bidirectional pins `uio_out[7:4]`.
3. **The Alarm Comparator:** Pure combinational logic constantly compares the running timer against a 4-bit hardware target defined by switches `ui_in[7:4]`. 
4. **Autonomous UART Transmitter (TX):** When the Alarm Comparator detects a match, an edge-detector triggers a hardcoded UART state machine. It autonomously streams the string `"VIT Vellore\r\n"` at 9600 baud out of `uio_out[0]`.
5. **UART Command Decoder (RX):** The chip listens to `uio_in[1]`. A 2-stage synchronizer protects against metastability, feeding a 16x oversampled receiver state machine. It decodes ASCII serial characters in real-time, allowing laptop control of the stopwatch (`S` = Start/Pause, `L` = Lap, `R` = Reset).

## How to test

Because this chip supports both physical and digital interfaces, testing is broken into two phases. Ensure the Tiny Tapeout board is powered and clocked at **10 MHz**.

### Phase 1: Physical Interface Verification
1. **Reset:** Press the system reset button (`rst_n` LOW) to clear all memory arrays. The 7-segment display will show `0`.
2. **Start/Pause:** Press the button wired to `ui_in[0]`. The display will toggle between running at 1Hz and freezing.
3. **Lap Memory:** While running, press `ui_in[1]`. Observe the output LEDs on `uio_out[7:4]` update to match the current digit on the 7-segment display.
4. **Target Alarm:** Set the DIP switches `ui_in[7:4]` to binary `0101` (5). When the 7-segment display hits `5`, the decimal point (`uo_out[7]`) will illuminate solid.

### Phase 2: UART Telemetry Verification
1. Connect the `GND` of a USB-to-TTL Serial adapter to the board's Ground.
2. Connect the **RX** pin of the adapter to `uio_out[0]` (Chip TX).
3. Connect the **TX** pin of the adapter to `uio_in[1]` (Chip RX).
4. Open a serial terminal (PuTTY/TeraTerm) on your PC. Configure it to **9600 Baud, 8 Data Bits, No Parity, 1 Stop Bit (8N1)**.
5. **Bidirectional Control:** - Type `S` on your keyboard. The stopwatch will start/pause.
   - Type `L` on your keyboard. The lap memory will trigger.
   - Type `R` on your keyboard. The system will undergo a soft reset back to 0.
6. **Data Exfiltration:** Set your physical switches `ui_in[7:4]` to `3`. Type `S` to start the timer. The exact moment the timer hits 3, your serial terminal will receive the string: `VIT Vellore`.

## External hardware

To fully verify the capabilities of this ASIC, you will need:
* Tiny Tapeout Demo Board (or equivalent carrier board).
* 7-Segment Display PMOD connected to the dedicated output pins (`uo_out[0:7]`).
* Two tactile push-buttons connected to `ui_in[0]` and `ui_in[1]`.
* Standard DIP switches for `ui_in[7:4]`.
* **A 3.3V USB-to-TTL Serial Cable** (e.g., FTDI or CH340 based) for laptop bidirectional communication.
