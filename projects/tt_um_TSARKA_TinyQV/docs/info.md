<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a TinyQV RISC-V SoC wrapped for Tiny Tapeout with a Wishbone interconnect.

Main blocks:

- TinyQV CPU core and memory controller (`TinyQV/*`)
- Wishbone bridge (`TinyQV/wb_bridge.v`) from CPU data bus to peripherals
- GPIO8 peripheral on Wishbone (`Peripherals/GPIO/*`)
- UART16550 peripheral on Wishbone (`Peripherals/UART16550/*`)

The top-level module is `tt_um_TSARKA_TinyQV` in `src/project.v`.

Top-level pin behavior:

- `ui[7]` is the UART RX input.
- `uio[7:0]` carry the QSPI flash/RAM interface.
- `uo[0]` always mirrors UART TX.
- `ui[0]` selects the visible `uo[7:1]` bank:
  - `0`: `uo[7:1]` show `gpio_out[7:1]`
  - `1`: `uo[7:2]` show fixed debug/status signals and `uo[1]` shows one selected debug probe
- `ui[4:1]` select which debug probe is driven onto `uo[1]` while still feeding the GPIO input peripheral.
- `ui[1:0]` also act as the external interrupt request inputs consumed by the core.

Debug-mode output map:

- `uo[7]` = `interrupt_pending`
- `uo[6]` = `data_ready`
- `uo[5]` = `fetch_restart`
- `uo[4]` = `branch`
- `uo[3]` = `instr_ready`
- `uo[2]` = `instr_complete`
- `uo[1]` = `debug_bus[ui[4:1]]`
- `uo[0]` = `uart_tx`

The 16-entry selectable debug probe bus is:

- `0`: `instr_complete`
- `1`: `instr_ready`
- `2`: `instr_valid`
- `3`: `fetch_restart`
- `4`: `data_ready`
- `5`: `interrupt_pending`
- `6`: `branch`
- `7`: `gpio_irq`
- `8`: `early_branch`
- `9`: `ret`
- `10`: `reg_wen`
- `11`: `counter_0`
- `12`: `data_continue`
- `13`: `stall_txn`
- `14`: `stop_txn`
- `15`: `uart_irq`

Clocking:

- Project clock is configured for 40 MHz (`clock_hz: 40000000` in `info.yaml`).
- TinyTapeout hardening timing is aligned to this (`CLOCK_PERIOD: 25` ns in `src/config.json`).
- The project footprint is configured as a `6x2` Tiny Tapeout macro because the
  full TinyQV + Wishbone + UART16550 + GPIO SoC does not fit in a single tile.

## How to test

Run RTL verification locally with cocotb + Icarus:

```sh
python3 -m venv test/.venv
. test/.venv/bin/activate
pip install -r test/requirements.txt
make firmware
make test-golden
make test-rtl
make test-comprehensive
make synth-gate-netlist
make test-gatelevel-smoke
make test-gatelevel
```

Current tests cover:

- Golden-model unit checks for the Wishbone bridge, GPIO model, and UART model
- Fast DUT-facing RTL smoke for reset ownership, QSPI chip-select exclusivity, output muxing, debug selector truth-table, and UART mirroring
- Manual QSPI instruction regressions for randomized ALU behavior, register load/store, peripheral interleave, timer interrupt entry, and external IRQ entry
- Firmware-backed QSPI boot tests for GPIO, UART hello/prime output, loopback, timer, and IRQ handling
- Gate-level regressions that reuse the same behavioral QSPI model against either a synthesized sky130 netlist or the final Tiny Tapeout/OpenLane netlist
- A deep gate-level signoff suite with explicit flash/protocol checks at latency `1/2/3`, fixed-seed randomized ALU and memory stress, and full-program firmware sweeps on the stable lower latencies

Useful verification targets:

```sh
make test-firmware
make stage-gate-netlist
make test-gatelevel
make test-rtl-seeds
make test-comprehensive-seeds
make test-firmware-seeds
make test-gatelevel-smoke
make test-gatelevel-smoke-seeds
```

Notes:

- `make test-gatelevel-smoke` is the quick local confidence pass.
- `make test-gatelevel` is the deeper signoff-oriented pass and is intentionally much slower.
- The Tiny Tapeout `gds` `gl_test` job is intended to exercise the deep signoff-style gate-level flow, not only the smoke checks.

CI signoff is wired through repo-level targets in `Makefile` and the workflow files under `.github/workflows/`.

## External hardware

Optional external hardware for bring-up/demo:

- USB-UART bridge connected to:
  - `ui[7]` as UART RX input to SoC
  - `uo[0]` as UART TX output from SoC
- QSPI flash / RAM connected to `uio[7:0]` pins as documented in `info.yaml` pinout.
- Optional GPIO consumers on `ui[7:0]` / `uo[7:0]`.
- A switch or jumper on `ui[0]` to flip between GPIO view and debug view on `uo[7:1]`.
- Optional four-bit selector on `ui[4:1]` to step through the 16 debug probes exposed on `uo[1]` in debug mode.
