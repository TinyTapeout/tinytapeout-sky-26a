<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a research-grade True Random Number Generator (TRNG) based on the phase jitter of an 8-oscillator Ring Oscillator (RO) bank, with comprehensive characterization and debug features.

### Entropy Core

Eight independent Ring Oscillators are instantiated using Sky130 standard cells (NAND2 + inverter chains). One RO is "tunable" (3–31 stages via `ui_in[7:5]`), while seven have fixed prime-number lengths (13, 17, 19, 23, 29, 31, 37 stages) with varied drive strengths (`inv_1`, `inv_2`, `inv_4`) to maximize frequency diversity and prevent phase-locking.

### Entropy Pipeline (3 selectable modes)

- **Default (XOR→sync):** All 8 RO outputs are XORed together, then passed through a 4-stage synchronizer. This is the standard mode for maximum entropy mixing.
- **Sync-before-XOR** (`entropy_ctrl[0]=1`): Each RO is independently synchronized through a 2-stage synchronizer, then the 8 synchronized outputs are XORed. This provides independent sampling with better theoretical randomness properties.
- **Single-RO bypass** (`ctrl_reg[0]=1`): A single RO (selected by `freq_mux_sel`) is routed through a 4-stage synchronizer, bypassing the XOR combiner. This mode enables individual RO characterization and frequency measurement.

### Health Monitoring

Real-time NIST SP 800-90B compliant health monitors run continuously:
- **Repetition Count Test (RCT):** Detects stuck-at failures. Cutoff = 32 consecutive identical bits.
- **Adaptive Proportion Test (APT):** Detects bias over a sliding window. Window = 1024 bits, cutoff = 600 matches.

Failures trigger an alarm that drives the auto-tuner to cycle RO configurations. Debug registers provide real-time visibility into RCT count, APT match count, and individual test pass/fail status. A test injection mode allows deterministic alarm verification by inserting known bit patterns into the monitor input.

### Conditioning (7 selectable modes)

The conditioner processes the sampled entropy bits before output, selected via `ctrl_reg[7:5]`:

| Mode | Description |
|------|-------------|
| 0 | von Neumann corrector (default, bias elimination) |
| 1 | Bypass (raw bits, no conditioning) |
| 2 | Tent map (chaotic, 16-bit fixed-point) |
| 3 | Coupled Tent map (two coupled chaotic maps) |
| 4 | Logistic map (chaotic, 16-bit fixed-point) |
| 5 | Bernoulli map (chaotic, 16-bit fixed-point) |
| 6 | Lorenz map (chaotic, sequential multiply for area efficiency) |
| 7 | LFSR (32-bit linear feedback shift register) |

### Output Interfaces

- **Parallel:** 8-bit random bytes on `uo_out[7:0]` with valid strobe on `uio_out[0]`.
- **UART TX:** Random bytes streamed at 115200 baud on `uio_out[1]`.
- **UART RX:** Register read/write commands on `uio_in[2]` at 115200 baud. Provides full register access as an alternative to SPI.
- **SPI:** Register-based follower on `uio[3:6]` (CS_N, SCLK, MOSI, MISO). CPOL=0, CPHA=0.

### SPI / UART Register Map

| Address | R/W | Description |
|---------|-----|-------------|
| 0x00–0x02 | R | Frequency count (24-bit, LSB first) |
| 0x10 | R/W | Status / Freq mux select: `{3'b0, alarm, 1'b0, freq_mux_sel[2:0]}` |
| 0x11 | R | Random byte output |
| 0x12 | R | RO selection readback (auto-tuner output) |
| 0x13 | R/W | Control register (see below) |
| 0x14–0x1A | R | Conditioner state readback |
| 0x1B | R | NIST debug: `{rct_fail, apt_fail, rct_count[5:0]}` |
| 0x1C | R | APT match count [7:0] |
| 0x1D | R | Conditioner capability bitmask |
| 0x1E | R | APT match count [9:8] (bits [1:0]) |
| 0x20 | R/W | Scratchpad (link verification) |
| 0x21 | R/W | Entropy control register (see below) |

**Control register (0x13):**

| Bit(s) | Name | Description |
|--------|------|-------------|
| 0 | `ro_bypass` | 1 = single-RO mode (bypass XOR, RO selected by `freq_mux_sel`) |
| 1 | `force_manual` | 1 = ignore `auto_en` pin for RO tuning |
| 2 | `mask_alarm` | 1 = suppress NIST alarm for auto-tuning |
| 4:3 | `uo_mux_sel` | Output mux: 0=random byte, 1=freq count LSB, 2=status, 3=raw sampled_bit |
| 7:5 | `cond_sel` | Conditioner select (0–7, see table above) |

**Entropy control register (0x21):**

| Bit(s) | Name | Description |
|--------|------|-------------|
| 0 | `sync_before_xor` | 1 = sync each RO independently before XOR |
| 1 | `nist_inject_en` | 1 = enable NIST test injection (overrides entropy source for monitor) |
| 2 | `nist_inject_bit` | Bit value to inject when injection is enabled |
| 3 | `uart_stream_en` | 1 = stream random bytes on UART TX (default off) |
| 7:4 | reserved | |

### UART Command Protocol

The UART command interface mirrors the SPI register protocol over a 2-wire UART connection (115200 baud, 8N1):

- **Write:** Send `{1, addr[6:0]}` then `{data[7:0]}` (2 bytes). Bit 7 of byte 1 = 1 for write.
- **Read:** Send `{0, addr[6:0]}` then `{0x00}` (dummy byte). Device responds with 1 byte on TX containing the register value.

This provides a fallback interface if SPI is unavailable, using only the UART TX/RX pins.

## How to test

### Quick Start

1. Set `ui_in[3]` (Enable) to `1`. Random data flows on `uo_out` and the UART TX pin immediately.
2. Verify SPI link: write `0xA5` to scratchpad register `0x20`, read it back.
3. Verify UART link: send `{0x80|0x20, 0x5A}` on UART RX to write `0x5A` to scratchpad, send `{0x20, 0x00}` to read it back.

### RO Characterization

1. Enable bypass mode: write `ctrl_reg` (0x13) = `0x01`.
2. Select each RO via `freq_mux_sel` (write to 0x10).
3. Read frequency count from 0x00–0x02 (24-bit).
4. Sweep tunable RO0 via `ui_in[7:5]` (0–7) and record frequency vs. chain length.

### NIST Health Monitor Testing

1. Enable test injection: write `entropy_ctrl` (0x21) = `0x06` (inject constant 1s).
2. Wait ~50 clock cycles. Read 0x1B to verify `rct_fail` (bit 7) = 1.
3. Switch to inject 0s: write 0x21 = `0x02`. Read 0x1B to verify count reset.
4. Disable injection: write 0x21 = `0x00`.

### Conditioner Testing

Set `ctrl_reg[7:5]` to select each conditioner (0–7). Collect random bytes from 0x11. Read conditioner state from 0x14–0x1A. Check capability bitmask at 0x1D.

See [test_plan.md](test_plan.md) for the comprehensive silicon test and characterization plan.

## External hardware

None required. Standard Tiny Tapeout carrier board. UART TX/RX on `uio[1:2]` and SPI on `uio[3:6]` are available on the bidirectional PMOD connector. UART pins follow the Digilent Pmod UART standard (TXD=uio[1], RXD=uio[2]).
