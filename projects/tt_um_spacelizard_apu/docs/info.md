## How it works

Spacelizard APU is a tiny 8-bit arithmetic processing unit.

It contains:

- 8-bit accumulator register `A`
- 8-bit register `B`
- flags: zero `Z`, carry `C`, negative `N`, overflow `V`
- 8-byte internal RAM
- arithmetic, logic, shift, and rotate operations

The control interface uses `ui_in`:

- `ui_in[7]` = `EXEC` strobe
- `ui_in[6:4]` = opcode
- `ui_in[3:0]` = argument

The data bus uses `uio_in` and `uio_out`.

`uo_out[7:0]` always shows the current value of register `A`.

RAM uses only `arg[2:0]`, so addresses are `0` to `7`.

## Instruction summary

| Opcode | Function |
|---|---|
| `000` | load/move/clear registers |
| `001` | arithmetic: add/sub |
| `010` | logic: and/or/xor/not |
| `011` | shifts/rotates |
| `100` | write RAM |
| `101` | read RAM into `A` |
| `110` | read register/status to `uio_out` |
| `111` | read RAM directly to `uio_out` |

## How to test

Apply a command on `ui_in`, put data on `uio_in` if needed, then pulse `EXEC` high for one clock cycle.

Example: load `A = 0x12`

- Set `uio_in = 0x12`
- Set `ui_in = 0b10000000`
- Clock once
- Set `ui_in = 0b00000000`
- `uo_out` should show `0x12`

Example: add `B` into `A`

- Load `A`
- Load `B`
- Pulse command `opcode = 001`, `arg = 0`
- Result appears on `uo_out`

The included cocotb test can be run with:

```sh
make -C test