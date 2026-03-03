## Overview

RISCY-V02 is a 16-bit RISC processor that is logically pin-compatible with the
WDC 65C02. Adjusted for lack of a usable SRAM IP on Tiny Tapeout, the design
fits roughly within the same transistor count (~14K SRAM-adjusted) as an
off-the-shelf model of the 6502 on the same process (+5%). This is comparable
to the 11K of a 65C02, so we're in the right ballpark; hand layout would of
course do much better.

In comparison to the 6502, it provides:

| RISCY-V02 | 6502 |
| --- | --- |
| 8x 16-bit registers | 3x 8-bit registers |
| 2-cycle 16-bit arithmetic | 2/3-cycle 8-bit arithmetic |
| 2-cycle variable-width shifts (arithmetic or logical) | 2-3 cycle 1-bit logical shifts |
| 2-cycle interrupt entry, 3-cycle exit | 7-cycle interrupt entry, 6 cycle exit |
| 4-cycle calls, 3-4 cycle returns | 6-cycle calls/returns |
| 2-byte instructions | 1-3 byte instructions, ~2.25 bytes avg (Megaman 5) |
| 3-cycle 16-bit stack-relative load/store byte | 5/6-cycle 16-bit stack-relative load/store byte |
| 19,628 transistors (SKY130) | 13,176 transistors (SKY130) |
| 13,844 SRAM-adjusted transistors | 13,176 SRAM-adjusted transistors |

This project exists to provide evidence against a notion floating around in the
retrocomputing scene: that the 6502 was a "local optima" in the design space
of processors in its transistor budget. This never sat right with me, because
it implies that we haven't learned anything about how to make CPUs in the
intervening 40 years, and yet its design is full of things now generally
considered to be bad ideas: microcode PLAs, a large selection of borderline
useless addressing modes available on questionable instructions, hardware BCD.
One of the major points of RISC is that this area is better spent on things
that make the processor faster: pipelining, barrel shifters, and more
registers! This design does exactly that.

**Contents**

**How it works** — [Architecture](#architecture) · [Bus Protocol](#bus-protocol) · [Pinout](#pinout) · [Board-Level Timing](#board-level-timing)

**Instruction Set** — [Registers](#register-naming-convention) · [Reference](#instruction-reference) · [Notes](#notes) · [Idioms](#idioms) · [Code Comparison](#code-comparison-riscy-v02-vs-6502)

**Execution Model** — [Pipeline](#pipeline-and-cycle-counts) · [Reset](#reset) · [Interrupts](#interrupts) · [Self-Modifying Code](#self-modifying-code) · [RDY and SYNC](#rdy-and-sync-signals)

**Demo Board Firmware**

**Reference** — [TT Mux Timing](#tt-mux-timing) · [Demux](#demux-reconstructing-the-bus) · [Instruction Encoding](#instruction-encoding) · [SRAM Analysis](#register-file-sram-analysis)

# How it works

## Architecture {#architecture}

- **8x 16-bit general-purpose registers**: R0-R7 (3-bit encoding)
- **16-bit program counter**
- **T flag**: single-bit condition flag, set by comparisons (CLT, CLTU, CEQ, CLTI, CLTUI, CEQI), shift-through-T instructions (SLLT, SRLT, RLT, RRT), and SRW; tested by BT/BF branches
- **I flag**: interrupt disable (1 = disabled)
- **ESR**: 2-bit exception status register {I, T}, saved on interrupt entry, restored by RETI
- **EPC**: 16-bit exception PC, saved on interrupt entry
- **Fixed 16-bit instructions**: fetched low byte first
- **2-stage pipeline**: Fetch,Execute with speculative fetch and redirect

## Bus Protocol {#bus-protocol}

Like the 65C02, but unlike the 6502, the RISCY-V02 operates as a modern
edge-triggered design on a single clock. Unfortunately, TT doesn't provide
enough pins to implement the 6502's pinout. However, the 65c02 is negedge
triggered, and it produces its non-write output at some point after the
negedge, and its write output at some point after the following posedge. Both
are largely expected to be latched at the following negedge.

Accordingly, we adjust the timing so that the pins are exposed in two phases:
address and data. At negedge, the address pins are exposed for the system to
latch on the following posedge. Then, the pins are muxed over to expose the
control outputs and the data (read or write), to be latched on the following
negedge. Control inputs stay consistent between the two phases.

## Pinout {#pinout}

**Address Phase**
- `uo_out[7:0]` = AB[7:0]
- `uio_out[7:0]` = AB[15:8] (all output)

**Data Phase**
- `uo_out[0]` = RWB (1 = read, 0 = write)
- `uo_out[1]` = SYNC (1 = at instruction boundary)
- `uo_out[7:2]` = 0
- `uio[7:0]` = D[7:0] (bidirectional; output during writes, input during reads)

**Control inputs**
- `ui_in[0]` = IRQB (active-low interrupt request, level-sensitive)
- `ui_in[1]` = NMIB (active-low non-maskable interrupt, edge-triggered)
- `ui_in[2]` = RDY (active-high ready signal)

## Board-Level Timing {#board-level-timing}

The SDC models the full round-trip through the TT mux (see
TT Mux Timing below for details). All constraints are STA-verified
at the board pin boundary — the numbers below are what external memory and
peripherals actually see.

| Parameter | Value | Notes |
|---|---|---|
| Clock period | 63ns (15.9 MHz) | fMax, all corners clean |
| Output hold (all) | >11ns after launching edge | Guaranteed by mux path delay (see below) |
| Input setup | before negedge | All inputs captured on negedge clk |
| Input hold | 0ns | DFF hold times are negative across all corners |

**Maximum clock speed.** STA-verified fMax is **15.9 MHz** (63ns period,
all 9 corners clean with production mux timing constraints). At 62ns the design
fails timing at the slow corner.

# Instruction Set

## Register Naming Convention {#register-naming-convention}

| Register | Name | Purpose |
|---|---|---|
| R0 | a0 | Argument / implicit base (I-type memory) |
| R1 | a1 | Argument |
| R2 | a2 | Argument |
| R3 | t0 | Temporary |
| R4 | s0 | Callee-saved |
| R5 | s1 | Callee-saved |
| R6 | ra | Return address (JAL/JALR write PC+2 here; return via `JR R6, 0`) |
| R7 | sp | Stack pointer |

Two registers have architectural roles: R0 is the implicit base for I-type loads and stores (`R0 + sext(imm8)`), and R7 is the stack pointer for SP-relative memory instructions. The remaining six are truly general-purpose. Comparisons write to the T flag rather than a destination register, so all eight GPRs are available as operands.

The 3/1/2 split (argument/temporary/callee-saved) among the six free registers follows the RV32E calling convention's ratios: after removing ra, sp, and the special-purpose registers (zero, gp, tp), RV32E allocates 6/11 argument, 3/11 temporary, and 2/11 callee-saved. Scaled to 6 registers and rounded, that gives 3, 1, 2.

R6 is a normal GPR — callee-saved, and interrupt handlers that use it must save and restore it manually. The interrupt return address lives in EPC, not R6. R-type loads and stores bypass the R0 convention, allowing explicit selection of both data register and base with no offset.

## Instruction Reference {#instruction-reference}

All 61 instructions are fixed 16-bit (2 bytes). Immediates are sign-extended by default; ANDI, ORI, and CLTUI zero-extend instead. PC-relative offsets (branches, J, JAL, AUIPC) are all relative to PC+2 (address of next instruction); the assembler's encoded immediate accounts for this. "Page crossing" means the upper byte of the target address differs from PC+2.

**Effect column notation:**

| Notation | Meaning |
|---|---|
| rd, rs | Destination/source register |
| rs1, rs2 | Source registers (R-type) |
| immN | N-bit immediate from instruction |
| shamt | Shift amount (4-bit immediate) |
| sext() | Sign-extend to 16 bits |
| zext() | Zero-extend to 16 bits |
| MEM[] | Byte memory access |
| MEM16[] | Word (16-bit) memory access |
| <s | Signed less-than |
| {a, b} | Bit concatenation |
| [n:m] | Bit slice (MSB:LSB) |

**Arithmetic & Logic**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| ADD | Add | rd = rs1 + rs2 | 2 | |
| ADDI | Add immediate | rd += sext(imm8) | 2 | |
| SUB | Subtract | rd = rs1 - rs2 | 2 | |
| AND | And | rd = rs1 & rs2 | 2 | |
| ANDI | And immediate | rd &= zext(imm8) | 2 | |
| OR | Or | rd = rs1 \| rs2 | 2 | |
| ORI | Or immediate | rd \|= zext(imm8) | 2 | |
| XOR | Xor | rd = rs1 ^ rs2 | 2 | |
| XORI | Xor immediate | rd ^= sext(imm8) | 2 | |

**Shifts**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| SLL | Shift left logical | rd = rs1 << rs2[3:0] | 2 | |
| SLLI | Shift left immediate | rd <<= shamt | 2 | |
| SLLT | Shift left, link T | T = rd[15]; rd = {rd[14:0], 0} | 2 | |
| RLT | Rotate left through T | T = rd[15]; rd = {rd[14:0], old_T} | 2 | Note 4 |
| SRL | Shift right logical | rd = rs1 >> rs2[3:0] (logical) | 2 | |
| SRLI | Shift right logical imm | rd >>= shamt (logical) | 2 | |
| SRLT | Shift right, link T | T = rd[0]; rd = {0, rd[15:1]} | 2 | |
| RRT | Rotate right through T | T = rd[0]; rd = {old_T, rd[15:1]} | 2 | Note 4 |
| SRA | Shift right arithmetic | rd = rs1 >> rs2[3:0] (arithmetic) | 2 | |
| SRAI | Shift right arith imm | rd >>= shamt (arithmetic) | 2 | |

**Comparisons**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| CLT | Compare <s | T = (rs1 <s rs2) | 2 | |
| CLTI | Compare <s immediate | T = (rs <s sext(imm8)) | 2 | |
| CLTU | Compare < | T = (rs1 < rs2) | 2 | |
| CLTUI | Compare < immediate | T = (rs < zext(imm8)) | 2 | |
| CEQ | Compare == | T = (rs1 == rs2) | 2 | |
| CEQI | Compare == immediate | T = (rs == sext(imm8)) | 2 | |

**Branches**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| BZ | Branch if zero | if rs == 0: PC += sext(imm8) << 1 | 2 / 3-4 | Note 1 |
| BNZ | Branch if non-zero | if rs != 0: PC += sext(imm8) << 1 | 2 / 3-4 | Note 1 |
| BT | Branch if T set | if T == 1: PC += sext(imm8) << 1 | 2 / 3-4 | Note 1 |
| BF | Branch if T clear | if T == 0: PC += sext(imm8) << 1 | 2 / 3-4 | Note 1 |

**Loads**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| LI | Load immediate | rd = sext(imm8) | 2 | |
| LUI | Load upper immediate | rd = imm8 << 8 | 2 | |
| AUIPC | Add upper imm to PC | rd = (PC+2) + (imm8 << 8) | 2 | |
| LW | Load word | rd = MEM16[R0 + sext(imm8)] | 4 | Note 2 |
| LWS | Load word (SP) | rd = MEM16[R7 + sext(imm8)] | 4 | Note 2 |
| LWR | Load word (register) | rd = MEM16[rs1] | 4 | Note 2 |
| LB | Load byte signed | rd = sext(MEM[R0 + sext(imm8)]) | 3 | |
| LBS | Load byte signed (SP) | rd = sext(MEM[R7 + sext(imm8)]) | 3 | |
| LBR | Load byte signed (reg) | rd = sext(MEM[rs1]) | 3 | |
| LBU | Load byte unsigned | rd = zext(MEM[R0 + sext(imm8)]) | 3 | |
| LBUS | Load byte unsigned (SP) | rd = zext(MEM[R7 + sext(imm8)]) | 3 | |
| LBUR | Load byte unsigned (reg) | rd = zext(MEM[rs1]) | 3 | |

**Stores**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| SW | Store word | MEM16[R0 + sext(imm8)] = rs | 4 | Note 2 |
| SWS | Store word (SP) | MEM16[R7 + sext(imm8)] = rs | 4 | Note 2 |
| SWR | Store word (register) | MEM16[rs1] = rs2 | 4 | Note 2 |
| SB | Store byte | MEM[R0 + sext(imm8)] = rs[7:0] | 3 | |
| SBS | Store byte (SP) | MEM[R7 + sext(imm8)] = rs[7:0] | 3 | |
| SBR | Store byte (register) | MEM[rs1] = rs2[7:0] | 3 | |

**Jumps & Calls**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| J | Jump | PC += sext(imm10) << 1 | 3-4 | Note 3 |
| JR | Jump register | PC = rs + sext(imm8) | 3-4 | Note 3 |
| JAL | Jump and link | R6 = PC+2; PC += sext(imm10) << 1 | 4 | |
| JALR | Jump and link register | R6 = PC+2; PC = rs + sext(imm8) | 4 | |

**System**

| Mnemonic | Name | Effect | Cycles | |
|---|---|---|---|---|
| CLI | Clear interrupt disable | I = 0 | 2 | Note 5 |
| SEI | Set interrupt disable | I = 1 | 2 | Note 5 |
| SRR | Status register read | rd = {12'b0, ESR, I, T} | 2 | |
| SRW | Status register write | ESR = rs[3:2]; {I, T} = rs[1:0] | 2 | Note 5 |
| EPCR | Read EPC | rd = EPC | 2 | |
| EPCW | Write EPC | EPC = rs | 2 | |
| INT | Software interrupt | ESR={I,T}; EPC=PC+2; I=1; PC=(vec+1)*2 | 3 | Note 5, Note 7 |
| RETI | Return from interrupt | {I, T} = ESR; PC = EPC | 3 | Note 5, Note 6 |
| WAI | Wait for interrupt | halt until interrupt | 2 / halt | Note 8 |
| STP | Stop | halt until reset | 1 | |

## Notes {#notes}

1. **BZ/BNZ/BT/BF** — Range -256 to +254 bytes. BZ/BNZ test full 16-bit register. Not-taken: 2cy, taken same-page: 3cy, page-crossing: 4cy.

2. **LW/LWS/LWR/SW/SWS/SWR** — Word transfers low byte first.

3. **J/JR** — Same-page: 3cy, page-crossing: 4cy. J range: -1024 to +1022 bytes.

4. **RLT/RRT** — 17-bit rotate through T (6502 ROL/ROR equivalent).

5. **I-flag atomicity** — All instructions that modify I (CLI, SEI, SRW, INT, RETI) take effect atomically at the dispatch boundary. The new I value gates IRQ in the same combinational evaluation where the instruction completes, so there is no window where the old I is visible. CLI/RETI/SRW restoring I=0 can fire a pending IRQ on the same cycle; SEI/INT setting I=1 blocks it.

6. **RETI** — Restores both I and T from ESR. If ESR.I=0, see note 5.

7. **INT** — Unconditional (ignores I).

8. **WAI** — PC increments past WAI before halt. If I=1, wakes without handler entry.

## Idioms {#idioms}

- **NOP** — `ADDI R0, 0` (encoding `0x0000`).
- **Load 16-bit immediate** — `LUI rd, hi(imm16); ADDI rd, lo(imm16)`. When `lo` has bit 7 set, use `hi+1` (same as RISC-V).
- **Bitwise NOT** — `XORI rd, -1` (`XORI` sign extends `imm8`)
- **T flag to boolean** — `SRR rd; ANDI rd, 1`.
- **PC-relative data** — `AUIPC rd, hi(imm16); LW rd, lo(imm16)` (or SW/JR). See above for 16-bit immediate handling.
- **Far call** — `LUI rd, hi(imm16); JALR rd, lo(imm16)`. Return: `JR R6, 0`. Alternatively, `AUIPC` for PC-relative addressing.
- **Nested interrupts** — Stack EPC and the upper two bits of SRR (ESR), then restore them on entry.
- **Software breakpoint** — `INT 1` (BRK): handler at $0004.

## Code Comparison: RISCY-V02 vs 6502 {#code-comparison-riscy-v02-vs-6502}

Side-by-side assembly for common routines, comparing cycle counts and code sizes. The [full comparison with annotated assembly](https://github.com/mysterymath/riscyv02-sky/blob/main/docs/code-comparison.md) shows every instruction. 6502 library routines use [cc65](https://github.com/cc65/cc65) runtime implementations where applicable. All cycle counts assume same-page branches.

| Routine | 6502 | RISCY-V02 | Speedup | 6502 Size | RISCY-V02 Size |
|---|---|---|---|---|---|
| memcpy | 14.5 cy/byte | 8.5 cy/byte | 1.7× | 38 B | 28 B |
| strcpy | 18 cy/char | 13 cy/char | 1.4× | 18 B | 12 B |
| 16×16 multiply | ~536 cy | ~232 cy | 2.3× | 34 B | 20 B |
| 16÷16 division | ~720 cy | ~280 cy | 2.6× | 37 B | 22 B |
| CRC-8 (SMBUS) | 101 cy/byte | 100 cy/byte | 1.0× | 22 B | 32 B |
| CRC-16/CCITT | 227 cy/byte | 100 cy/byte | 2.3× | 43 B | 34 B |
| Raster bar IRQ | ~39.5 cy | ~40 cy | 1.0× | 15 B | 24 B |
| RC4 keystream | 61 cy/byte | 38 cy/byte | 1.6× | 34 B | 32 B |

**32-bit arithmetic** (inline sequences, not calls):

| Operation | 6502 Cycles | RISCY-V02 Cycles | Speedup | 6502 Size | RISCY-V02 Size |
|---|---|---|---|---|---|
| ADD / SUB | 38 | 9–10 | 3.8–4.2× | 25 B | 10 B |
| AND / OR / XOR | 36 | 4 | 9.0× | 24 B | 4 B |
| SLL / SRL (N=8) | 204 | 19 | 10.7× | 15 B | 26 B |
| SRA (N=8) | 244 | 19 | 12.8× | 18 B | 26 B |

**Packed BCD addition** (6502 has hardware decimal mode):

| Width | 6502 Cycles | RISCY-V02 Cycles | Speedup | 6502 Size | RISCY-V02 Size |
|---|---|---|---|---|---|
| 2-digit (8-bit) | 9 | 28 | 0.3× | 5 B | 28 B |
| 4-digit (16-bit) | 24 | 30 | 0.8× | 15 B | 30 B |
| 8-digit (32-bit) | 42 | 68 | 0.6× | 25 B | 68 B |

RISCY-V02 is faster at almost everything — the 16-bit data path eliminates byte-at-a-time serialization. The exceptions: CRC-8 and raster bar IRQ are ties (both dominated by 8-bit operations that map naturally to the 6502), and packed BCD is a clear 6502 win (hardware `SED` mode vs software nibble correction).

# Execution Model

Internals of the CPU pipeline, interrupt handling, and special signals.

## Pipeline and cycle counts {#pipeline-and-cycle-counts}

The 2-stage pipeline (Fetch and Execute) overlaps fetch of the next instruction with execution of the current one. For sequential code and not-taken branches, the execute cost is completely hidden — throughput is limited by the 2-cycle fetch. Only taken branches and jumps pay execute cost directly, because the redirect flushes the speculative fetch.

Throughput is measured from one instruction boundary (SYNC) to the next. Three factors determine the count:

1. **Fetch floor (2 cycles):** fetching the next instruction always takes 2 cycles (lo byte, hi byte). Execute overlaps with fetch, so any instruction with 2 or fewer execute cycles is fetch-limited at 2.
2. **Bus contention (+1 per byte transferred):** memory loads/stores take the bus from fetch to transfer data. The 2 address-compute cycles (E_EXEC_LO, E_EXEC_HI) are hidden behind the fetch, but each bus transfer cycle adds 1 to the total.
3. **Redirect penalty (execute exposed):** taken branches and jumps flush the speculative fetch, so execute cycles are no longer hidden. Total = execute cycles + 2 fresh fetch cycles.

| Instruction | Cycles | Exec | Why |
|---|---|---|---|
| ALU / shifts / compares | 2 | 2 | Fetch-limited (execute hidden) |
| SRR / EPCR / EPCW | 2 | 2 | Fetch-limited (execute hidden) |
| SEI / CLI / SRW | 2 | 1 | Fetch-limited (execute hidden) |
| Branch not taken | 2 | 1 | Fetch-limited (execute hidden) |
| Branch taken, same page | 3 | 1 | Redirect: 1 execute + 2 fetch |
| Branch taken, page crossing | 4 | 2 | Redirect: 2 execute + 2 fetch |
| Byte load / store | 3 | 3 | Fetch floor + 1 bus transfer |
| Word load / store | 4 | 4 | Fetch floor + 2 bus transfers |
| J same page | 3 | 1 | Redirect: 1 execute + 2 fetch |
| J page crossing / JAL | 4 | 2 | Redirect: 2 execute + 2 fetch |
| JR same page | 3 | 1 | Redirect: 1 execute + 2 fetch |
| JR page crossing / JALR | 4 | 2 | Redirect: 2 execute + 2 fetch |
| IRQ / NMI | 2 | 0 | Redirect at dispatch: 0 execute + 2 fetch |
| RETI / INT | 3 | 1 | Redirect: 1 execute + 2 fetch |
| WAI (wake) | 2 | 1 | Fetch-limited (execute hidden) |
| WAI (halt) | -- | -- | Halted until interrupt |
| STP | 1 | 1 | Enters halt (no fetch) |

**Exec** — cycles the execute unit is busy before the CPU can recognize a pending interrupt. For fetch-limited instructions (exec ≤ 2), this is hidden behind the 2-cycle fetch and doesn't affect throughput, but a 1-cycle exec allows an interrupt to preempt the second fetch cycle.

## Reset {#reset}

- PC is set to $0000 and execution begins
- I (interrupt disable) is set to 1 -- interrupts are disabled
- T (condition flag) is cleared to 0
- ESR is set to {I=1, T=0}
- All registers are cleared to zero

**Reset deassertion requirement:** Reset may be asserted asynchronously, but it
must deassert synchronous to `negedge clk`. This guarantees the CPU does not
reset halfway through a cycle of the bus protocol, and it also ensures correct
setup and hold timing. A 2-DFF reset synchronizer on the negedge satisfies this
requirement in systems where reset may arrive asynchronously.

## Interrupts {#interrupts}

RISCY-V02 supports maskable IRQ and non-maskable NMI interrupts.

**Vector table** (2-byte spacing; IRQ last for inline handler):

| Vector ID | Address | Trigger |
|---|---|---|
| RESET | $0000 | RESB rising edge |
| 0 (NMI) | $0002 | NMIB falling edge, non-maskable |
| 1 (BRK) | $0004 | BRK instruction, unconditional |
| 2 (IRQ) | $0006 | IRQB low, level-sensitive, masked by I=1 |

Each vector slot is one instruction (2 bytes) -- enough for a J trampoline to
reach the actual handler. IRQ is placed last so its handler can run inline
without a jump, since nothing follows it.

NMI is edge-triggered; the behavior is broadly similar to the 6502. NMI has
priority over IRQ; if both are pending simultaneously, NMI is taken first, and
the subsequent I=1 masks the IRQ. NMI's state is sampled on negedge.

**Warning:** Unlike the 6502, RETI from an NMI handler is undefined behavior.
NMI overwrites EPC and ESR unconditionally, so if an NMI interrupts an IRQ
handler before it saves EPC/ESR (via EPCR/SRR), the IRQ's return state is lost.
SRR/SRW include ESR in bits [3:2], so a single SRR/SRW pair saves and restores
everything needed for interrupt nesting.
NMI handlers typically reset, halt, or spin. This is typical of modern RISC
CPUs: NMI is intended for fatal hardware fault handling.

**Interrupt latency:** 2 cycles from instruction completion in execute stage to
first handler instruction fetch (dispatch-time redirect + 2-cycle vector
fetch). NMI edge detection is combinational -- if the falling edge arrives on
the same cycle that the FSM is ready, the NMI is taken immediately with no
additional detection delay.

**Dispatch:** Hardware interrupt entry (IRQ, NMI) is handled at dispatch time
in a single cycle. When the FSM is ready (instruction completing or idle), the
hardware saves EPC and ESR, sets I=1, and redirects the PC to the vector
address. The 2-cycle vector fetch is the only latency. INT and RETI are normal
1-execute-cycle instructions (like same-page JR): they dispatch to E_EXEC_LO,
complete in one cycle, then the 2-cycle target fetch follows (3 cycles total).

**Interrupt entry:**
1. Complete the current instruction
2. Save ESR = {I, T} -- status flags at interrupt entry
3. Save EPC = next_PC -- clean 16-bit return address
4. Set I = 1 -- disable further interrupts
5. Jump to vector entry

**Interrupt return (RETI instruction):**
1. Restore {I, T} from ESR
2. Jump to EPC

**Exception state:** EPC is a standalone 16-bit register holding the clean return address. ESR is a 2-bit register holding {I, T} at the time of interrupt entry. Neither is directly addressable through normal register fields. EPC is accessible through EPCR/EPCW. SRR reads `{12'b0, ESR[1:0], I, T}` and SRW writes `ESR = rs[3:2], {I, T} = rs[1:0]`, providing direct access to both live flags and saved exception state in a single instruction. All GP registers (R0-R7) are directly accessible in interrupt context -- there is no register banking.

## Self-Modifying Code {#self-modifying-code}

Because the next instruction's fetch overlaps with the current instruction's execution, **a store is never visible to the immediately following instruction fetch**. The instruction two past the store sees the new value. To fence, insert any instruction between the store and the modified code:

```
SB [target]     ; store writes to 'target' address
NOP             ; fence — target's fetch happens during NOP's execution
target:         ; this instruction sees the stored value
```

A single fence instruction is always sufficient, including for word stores.


## RDY and SYNC Signals {#rdy-and-sync-signals}

These provide W65C02S-compatible hooks for wait-state insertion, DMA, and single-step debugging — any system that needs to stall the CPU or observe instruction boundaries can use the same techniques as existing 65C02 designs.

### RDY (Ready Input)

When `ui_in[2]` is low, the processor halts atomically: all CPU state freezes (PC, registers, pipeline, ALU carry), bus outputs remain stable, and the bus protocol mux continues toggling. The processor resumes on the next edge after RDY returns high. RDY halts on both reads and writes, matching W65C02S behavior.

### SYNC (Instruction Boundary Output)

`uo_out[1]` during the data phase is high for one cycle when a new instruction begins execution.

### Single-Step and Wait-State Protocols

To **single-step**, monitor SYNC during data phases and pull RDY low when it goes high. The CPU halts at the instruction boundary. Leave RDY high while cycling the clock, then pull it low again when SYNC reasserts.

For **wait states**, external logic decodes the address during the address phase and pulls RDY low before the data-phase clock edge if the access needs more time. When the memory is ready, RDY goes high and the CPU continues.

# Demo Board Firmware

The TT demoboard's RP2350 (Raspberry Pi Pico 2) can emulate 64 KiB of SRAM and a simple UART peripheral entirely in software, removing the need for external memory hardware. The firmware lives in `firmware/` and uses both RP2350 cores: core 1 runs a tight bus-servicing loop that responds to the CPU's muxed bus protocol, while core 0 bridges a memory-mapped UART peripheral to the demoboard's USB serial port.

### Building and Flashing

Prerequisites: CMake, Ninja, and the [Pico SDK](https://github.com/raspberrypi/pico-sdk) (v2.2.0). If `PICO_SDK_PATH` is not set, the build system fetches the SDK automatically.

```
cd firmware
cmake -B build -G Ninja
cmake --build build
```

Flash `build/riscyv02_firmware.uf2` by holding BOOTSEL while plugging in the Pico 2, then dragging the file to the USB mass-storage device that appears.

### Program Upload Protocol

Before starting the CPU, the firmware accepts a binary upload over USB serial:

1. Firmware prints a banner and `Ready` prompt.
2. Host sends: `L` `<addr_lo>` `<addr_hi>` `<len_lo>` `<len_hi>` `<data...>` — loads `len` bytes into `mem[addr]`.
3. Firmware prints `OK <len> bytes at 0x<addr>`. Repeat step 2 for additional segments (e.g., code at `0x0000`, vectors at `0x0008`).
4. Host sends: `G` — firmware launches core 1 and enters the UART bridge loop. Prints `Running`.
5. Host sends: Ctrl-R (`0x12`) during execution — firmware stops core 1, resets the project, prints `Reset`, and returns to step 1.

### Programming Workflow

The assembler is a Python API in `test/asm.py`. Write a Python script that imports `Asm`, builds a program, and calls `save_binary()` to produce a flat binary. Then use `firmware/upload.py` to upload and run it on the demo board.

**Prerequisites:** `pip install pyserial`

**Hello world example** (`hello.py`):

```python
#!/usr/bin/env python3
"""Hello world for RISCY-V02."""
import sys; sys.path.insert(0, 'test')
from asm import Asm

a = Asm()
a.lui(0, 0xFF)           # R0 = 0xFF00 (UART base)
a.la(1, 'msg')           # R1 = &msg
a.label('loop')
a.lbu_rr(2, 1)           # R2 = *R1
a.bz(2, 'done')          # if null, done
a.sb(2, 0)               # UART TX = R2
a.addi(1, 1)             # R1++
a.j('loop')
a.label('done')
a.stp()
a.label('msg')
a.string('Hello, world!\n')

a.save_binary('hello.bin')
print(f"Wrote {max(a.prog.keys())+1} bytes to hello.bin")
```

**Build and run** (standalone emulator, no hardware needed):

```
python hello.py                                    # produces hello.bin
python test/emu.py hello.bin                       # run in emulator
```

**Or upload to demo board:**

```
python hello.py                                    # produces hello.bin
python firmware/upload.py /dev/ttyACM0 hello.bin   # upload and run
```

**Expected output:**

```
Hello, world!
```

The upload script enters transparent terminal mode after launching, so any UART output from the program appears directly. Ctrl-C exits; Ctrl-R resets the board for re-upload without power cycling (`--reset` flag does this automatically before uploading).

### Memory Map

| Address | R/W | Function |
|---------|-----|----------|
| `0x0000`–`0xFEFF` | R/W | 64 KiB SRAM (byte-addressable) |
| `0xFF00` | W | UART TX — written byte is sent over USB serial |
| `0xFF01` | R | UART RX — reads the next byte received from USB serial |
| `0xFF02` | R | UART status — bit 0: TX ready, bit 1: RX data available |

The SRAM region covers the full 64 KiB address space except for the UART window at `0xFF00`–`0xFF02`. Reads from `0xFF00` and writes to `0xFF01`/`0xFF02` are don't-care (the firmware ignores them).

### Startup Sequence

The firmware initializes GPIO, selects the RISCY-V02 project on the TT mux, sets `ui_in` to `0x07` (IRQB=1, NMIB=1, RDY=1 — all inactive), resets the project, then enters the upload loop. Core 1 is launched only after receiving the `G` command, at which point it begins driving the clock and servicing the bus. No PWM is used — the clock is entirely software-driven.

### Bus Servicing (Core 1) — Software-Driven Clock

Core 1 drives the project clock directly via GPIO (`gpio_put`), advancing the ASIC one phase at a time. This eliminates all timing pressure — each phase takes as long as it needs, with zero bus contention. The loop:

1. **Address phase (clk LOW):** Read AB[7:0] from `uo_out` and AB[15:8] from `uio`. Speculatively prepare read data from the SRAM array or UART registers.
2. **Posedge (`gpio_put(clk, 1)`):** The ASIC latches the address and enters data phase.
3. **Data phase (clk HIGH):** Check RWB (`uo_out[0]`). On a read (RWB=1), drive `uio` with the prepared data byte. On a write (RWB=0), capture `uio` into the SRAM array or UART TX FIFO.
4. **Release uio, then negedge (`gpio_put(clk, 0)`):** The ASIC latches read data and returns to address phase.

Since the RP2350 *is* the memory system, a free-running PWM clock would create timing races. The software-driven clock is self-throttling, deterministic, and simpler to debug.

### UART Bridge (Core 0)

Core 0 runs the standard Pico SDK USB serial stack and bridges it to the memory-mapped UART peripheral. TX bytes flow through the RP2350's hardware multicore FIFO: core 1 pushes bytes when the CPU writes to `UART_TX_DATA` (`0xFF00`), and core 0 pops them and sends them over USB. RX bytes are single-buffered: core 0 reads from USB into `uart_rx_buf`, and the CPU reads them from `UART_RX_DATA` (`0xFF01`). The status register at `0xFF02` lets the CPU poll for TX readiness (`multicore_fifo_wready`) and RX data availability without side effects.

# Reference

Technical appendices for hardware design and tooling.

## TT Mux Timing {#tt-mux-timing}

The TT mux sits between the project tile and the board pins. It is a purely
combinational path — no registers in the data path. Every signal (clock in,
data/address out, data in) passes through it, adding asymmetric delay:

| Segment | Input (pad→project) | Output (project→pad) |
|---|---|---|
| IO pad (liberty, slow) | ~0.7–4ns | ~4–8ns |
| tt_ctrl (pad↔spine) | 2.75ns | 2.25ns |
| tt_mux (spine↔project) | 2.5ns | 7.5ns |
| **Total** | **~6–9ns** | **~14–18ns** |

IO pad delays vary by process (IHP vs SKY130); the tt_ctrl and tt_mux delays
are process-independent. The SDC conservatively models the full round-trip as
22ns (`set_output_delay 22`), which bounds all known process variants.

**Impact on output setup.** The mux adds a full round-trip penalty to output
setup: the clock arrives at the project late (input path delay), and the output
arrives at the board pin late (output path delay). The total round-trip cost is
~22ns. The SDC models this directly, so all remaining slack is real board-level
setup margin — enough for any reasonable external latch or SRAM setup time.

**Impact on output hold.** The mux *guarantees* board-level hold. Even at the
fast corner with minimum delays (mux clock input ~3ns + CK→Q ~0.3ns + mux
output ~8ns ≈ 11.3ns), the output transition at the board pin arrives >11ns
after the clock edge at the board pin. This far exceeds the ~2ns hold
requirement of typical external latches and SRAM. The mux makes an explicit
delay chain unnecessary.

**Pin-to-pin skew.** The mux path is not perfectly matched across all pins.
TT 3.5 silicon measurements show <2ns of pin-to-pin skew. The SDC adds this
as setup-only clock uncertainty (`set_clock_uncertainty -setup`), since the skew
affects output setup margin but not internal hold paths.

## Demux: Reconstructing the Bus {#demux-reconstructing-the-bus}

The muxed TT pins must be demultiplexed back into separate address, data, and
control signals before connecting to SRAM, ROM, or peripherals. A reference
implementation is provided in
[`src/tt_um_riscyv02_demux.v`](https://github.com/mysterymath/riscyv02/blob/main/src/tt_um_riscyv02_demux.v);
what follows is a complete description of the technique.

### Address Latch

Capture `{uio_out, uo_out}` into a 16-bit posedge DFF at posedge clk. At that
instant, the chip's internal `mux_sel` is still 0 (address phase) because its
toggle FF hasn't fired yet, so the address is stable with tCQ hold time.

```
ADDR[15:0] <= {uio_out[7:0], uo_out[7:0]}   @ posedge clk
```

### RWB and SYNC: Safe-Default Gating

During the address phase (clk LOW), `uo_out` carries address bits — garbage if
interpreted as control signals. A naive approach (capturing RWB/SYNC into
negedge DFFs) leaves them one half-cycle stale, causing spurious writes on
write-to-read transitions when using standard SRAM write-enable formulas.

Instead, gate RWB and SYNC combinationally with clk to present safe defaults
during the address phase:

```
RWB  = uo_out[0] | ~clk     (1 = read/safe during address phase)
SYNC = uo_out[1] & clk      (0 = inactive during address phase)
```

During the data phase (clk HIGH), the real values pass through unmodified.

### Async SRAM Connection

With safe-defaulted RWB and PHI2 (= clk), the standard 65C02 SRAM formulas
work directly:

```
WE# = ~(PHI2 & ~RWB) = ~clk | uo_out[0]
OE# = ~(PHI2 &  RWB) = ~(clk & uo_out[0])
```

Both signals are forced inactive during the address phase (clk LOW), preventing
glitches. During the data phase:
- **Writes:** WE# goes LOW while clk is HIGH and RWB is 0. Data latches on the
  WE# rising edge (clk falling).
- **Reads:** OE# goes LOW while clk is HIGH and RWB is 1. Read data must be
  valid before the negedge for the CPU to capture it.

### Data Bus Direction

`DATA_OE` (derived from `uio_oe == 8'hFF`) is HIGH during both address phase
(address output) and write data phase. External bus transceivers should gate it
with PHI2:

```
DATA_DIR = PHI2 & DATA_OE    (1 = CPU driving, 0 = memory driving)
```

Or simply use WE#/OE# directly, which already incorporate the phase gating.


## Instruction Encoding {#instruction-encoding}

This section documents the binary encoding for tools and hardware implementors.

All 61 instructions are fixed 16-bit. Three properties drive the encoding: in formats with signed immediates (I, B, J) the sign bit is always ir[15], so sign extension runs in parallel with decode; the primary register field ir[7:5] is shared across I/SI/SYS/R-type formats, enabling a speculative register read before the opcode is fully decoded; and `0x0000` encodes ADDI R0, 0 (NOP). Immediates are sign-extended by default; ANDI, ORI, and CLTUI zero-extend instead.

| Format | Layout (MSB→LSB) | Used |
|---|---|---|
| I | `[imm8:8\|rs/rd:3\|opcode:5]` | 24 |
| B | `[imm8:8\|0:2\|funct1:1\|opcode:5]` | 2 |
| J | `[s:1\|imm[6:0]:7\|imm[8:7]:2\|funct1:1\|opcode:5]` | 2 |
| R | `[funct2:2\|rd:3\|rs2:3\|rs1:3\|opcode:5]` | 16 |
| SI | `[funct3:3\|0:1\|shamt:4\|rs/rd:3\|opcode:5]` | 7 |
| SYS | `[funct4:4\|0:4\|reg:3\|opcode:5]` | 10 |

In R-type, rs2 is at [10:8] and rd at [13:11].

### Opcode Table

```
--- I-type (opcode 0-23) ---
00000 (0)   ADDI
00001 (1)   LI
00010 (2)   LW
00011 (3)   LB
00100 (4)   LBU
00101 (5)   SW
00110 (6)   SB
00111 (7)   JR
01000 (8)   JALR
01001 (9)   ANDI
01010 (10)  ORI
01011 (11)  XORI
01100 (12)  CLTI
01101 (13)  CLTUI
01110 (14)  BZ
01111 (15)  BNZ
10000 (16)  CEQI
10001 (17)  LWS
10010 (18)  LBS
10011 (19)  LBUS
10100 (20)  SWS
10101 (21)  SBS
10110 (22)  LUI
10111 (23)  AUIPC

--- B-type (opcode 24, funct1 at [5]) ---
11000.000   BT
11000.001   BF

--- J-type (opcode 25, funct1 at [5]) ---
11001.0     J
11001.1     JAL

--- R-type (opcodes 26-29, funct2 at [15:14]) ---
Opcode 26 (R-ALU1): 00=ADD, 01=SUB, 10=AND, 11=OR
Opcode 27 (R-ALU2): 00=XOR, 01=SLL, 10=SRL, 11=SRA
Opcode 28 (R-MEM):  00=LWR, 01=LBR, 10=LBUR, 11=SWR
Opcode 29 (R-MISC): 00=SBR, 01=CLT, 10=CLTU, 11=CEQ

--- SI-type (opcode 30, funct3 at [15:13]: [15]=T, [14]=right, [13]=mode) ---
funct3=000  SLLI
funct3=010  SRLI
funct3=011  SRAI
funct3=100  SLLT
funct3=101  RLT
funct3=110  SRLT
funct3=111  RRT

--- SYS-type (opcode 31, funct4 at [15:12]) ---
funct4=0   SEI
funct4=1   CLI
funct4=2   WAI
funct4=3   STP
funct4=4   EPCR    (reg at [7:5])
funct4=5   EPCW    (reg at [7:5])
funct4=6   SRR     (reg at [7:5])
funct4=7   SRW     (reg at [7:5])
funct4=8   RETI
funct4=12+ INT     (vec 0-2 at [7:6]; vec 3 = NOP)

All other encodings execute as NOP (2-cycle no-op).
```

## Register File SRAM Analysis {#register-file-sram-analysis}

Standard cell synthesis implements the register file with DFFs (~28T each) and mux trees, but a real chip would use SRAM cells (~8T each) — the 8×16-bit 2R1W array is perfectly regular. This over-counting inflates the RISCY-V02 transistor count by ~5,800T. The [full SRAM analysis](https://github.com/mysterymath/riscyv02-sky/blob/main/docs/sram-analysis.md) designs an equivalent 8T SRAM register file from first principles, explains how the cells and clock phases work, and counts every transistor. Summary:

| Component | Transistors |
|---|---|
| Storage array (128 × 8T cells) | 1,024 |
| Write path (decode + drivers + staging) | 272 |
| Read path 1 (RW, differential) | 118 |
| Read path 2 (R-only, single-ended) | 86 |
| **Total** | **1,500** |

The SRAM-adjusted transistor count is computed by `transistor_count.py` from each build's `stat.json`.
