import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import re
import os
import binascii


async def enable_design(dut, mux_addr):
    dut._log.info(f"enabling design at mux address {mux_addr}")

    # reset the controller
    dut.ctrl_sel_inc.value = 0
    dut.ctrl_sel_rst_n.value = 0
    dut.ctrl_ena.value = 0
    await ClockCycles(dut.clk, 5)
    dut.ctrl_sel_rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    # send the number of pulses required
    for c in range(mux_addr):
        dut.ctrl_sel_inc.value = 1
        await ClockCycles(dut.clk, 1)
        dut.ctrl_sel_inc.value = 0
        await ClockCycles(dut.clk, 1)

    dut.ctrl_ena.value = 1


@cocotb.test()
async def test_mux(dut):
    clock = Clock(dut.clk, 100, unit="ns")  # 10 MHz
    cocotb.start_soon(clock.start())

    dut.uio_in.value = 0
    dut.ui_in.value = 0
    # select test design
    dut.reset_n.value = 0
    await enable_design(dut, 1)

    # with bit 0 of ui_in set to 0, module will copy inputs to outputs
    dut.ui_in.value = 0b0
    await ClockCycles(dut.clk, 5)  # wait until the wait state config is read
    dut.reset_n.value = 1

    dut._log.info("test loopback")
    for i in range(256):
        dut.uio_in.value = i
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == i

    # with bit 0 of ui_in set to 1, module will enable bidirectional outputs and put a counter on both output and bidirectional output
    dut.ui_in.value = 0b1

    # reset it
    dut.reset_n.value = 0
    await ClockCycles(dut.clk, 5)  # wait until the wait state config is read
    dut.reset_n.value = 1
    await ClockCycles(dut.clk, 2)  # sync

    dut._log.info("test counter")
    for i in range(256):
        assert dut.uo_out.value == dut.uio_out.value
        assert dut.uo_out.value == i
        await ClockCycles(dut.clk, 1)  # wait until the wait state config is read


@cocotb.test()
async def test_rom(dut):
    clock = Clock(dut.clk, 100, unit="ns")  # 10 MHz
    cocotb.start_soon(clock.start())

    dut.uio_in.value = 0
    dut.ui_in.value = 0
    # select ROM design
    dut.reset_n.value = 0
    await enable_design(dut, 0)

    await ClockCycles(dut.clk, 1)
    dut.reset_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Read ROM, addressing with ui_in (rst_n=1)")
    rom_data = bytearray(256)
    for byte_idx in range(len(rom_data)):
        dut.ui_in.value = byte_idx
        await ClockCycles(dut.clk, 1)
        rom_data[byte_idx] = dut.uo_out.value

    dut._log.info(f"Read ROM, addressing sequentially (rst_n=0)")
    dut.reset_n.value = 0
    rom_data_seq = bytearray(256)
    for byte_idx in range(len(rom_data_seq)):
        await ClockCycles(dut.clk, 1)
        rom_data_seq[byte_idx] = dut.uo_out.value

    text = rom_data[32:128].rstrip(b"\0").decode("ascii")
    items = {}
    for line in text.split("\n"):
        if len(line) == 0:
            break
        key, value = line.split("=", 2)
        items[key] = value

    dut._log.info(f"ROM start bytes: {binascii.hexlify(rom_data[:32], ' ').decode('ascii')}")
    dut._log.info(f"ROM text data: {items}")


    assert "shuttle" in items
    assert "repo" in items
    assert "commit" in items

    assert rom_data == rom_data_seq, "ROM contents differ when addressing sequentially"

    assert items["repo"] == os.environ.get("EXPECTED_REPO")
    assert re.match("^[0-9a-f]{8}$", items["commit"]) != None

    magic = rom_data[248:252]
    assert magic == b"TT\xFA\xBB"

    crc32 = int.from_bytes(rom_data[252:256], "little")
    assert crc32 == binascii.crc32(rom_data[0:252])
