<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Lorem ipsum dolor sit amet.

## How to test

**WORK IN PROGRESS**

This can be tested with MicroPython on the demo board.

First, set up some utility functions:
```python
CMD_WRITE_KEY_128 = 0x10
CMD_WRITE_BLOCK_64 = 0x20
CMD_START_ENCRYPT = 0x30
CMD_START_DECRYPT = 0x31
CMD_READ_BLOCK_64 = 0x40
CMD_READ_STATUS = 0x50

def spi_write_cmd_and_payload(spi, cmd, payload=None):
    spi_cs(0)
    spi.write(bytes([cmd]))
    if payload:
        spi.write(payload)
    spi_cs(1)

def spi_read_status(spi):
    spi_cs(0)
    spi.write(bytes([CMD_READ_STATUS]))
    status = spi.read(1)
    spi_cs(1)
    return status

def spi_read_block64(spi):
    spi_cs(0)
    spi.write(bytes([CMD_READ_BLOCK_64]))
    data = spi.read(8)
    spi_cs(1)
    return data

def wait_spi_done(spi, max_polls=1000):
    for _ in range(max_polls):
        status = spi_read_status(spi)
        if ((int.from_bytes(status, 'big') >> 2) & 0x1):
            return True
    return False

def encrypt(spi, plaintext, key):
    spi_write_cmd_and_payload(spi, CMD_WRITE_KEY_128, key)
    spi_write_cmd_and_payload(spi, CMD_WRITE_BLOCK_64, plaintext)
    spi_write_cmd_and_payload(spi, CMD_START_ENCRYPT)
    status = wait_spi_done(spi)
    if not status:
        return b''
    return spi_read_block64(spi)

def decrypt(spi, ciphertext, key):
    spi_write_cmd_and_payload(spi, CMD_WRITE_KEY_128, key)
    spi_write_cmd_and_payload(spi, CMD_WRITE_BLOCK_64, ciphertext)
    spi_write_cmd_and_payload(spi, CMD_START_DECRYPT)
    status = wait_spi_done(spi)
    if not status:
        return b''
    return spi_read_block64(spi)
```

Secondly, initialize SPI:
```python
spi_miso = tt.pins.pin_uo_out0
spi_cs = tt.pins.pin_ui_in2
spi_clk = tt.pins.pin_ui_in0
spi_mosi = tt.pins.pin_ui_in1

spi_miso.init(spi_miso.IN, spi_miso.PULL_DOWN)
spi_cs.init(spi_cs.OUT)
spi_clk.init(spi_clk.OUT)
spi_mosi.init(spi_mosi.OUT)

spi = machine.SoftSPI(baudrate=10000, polarity=0, phase=0, bits=8, firstbit=machine.SPI.MSB, sck=spi_clk, mosi=spi_mosi, miso=spi_miso)

spi_cs(1) # Initial value for CS
```
Then test encryption and decryption:
```python
key = bytes.fromhex("1b1a1918131211100b0a090803020100")
plain = bytes.fromhex("656b696c20646e75")
expected_ct = bytes.fromhex("44c8fc20b9dfa07a")

ct = encrypt(spi, plain, key)
print("Ciphertext:", ct.hex())
assert ct == expected_ct, "Encryption failed"

pt = decrypt(spi, ct, key)
print("Decrypted plaintext:", pt.hex())
assert pt == plain, "Decryption failed"
```

## External hardware

No external hardware is required.

The SIMON64/128 crypto module can be used through the RP2350 on the demo board, or optionally by connecting an external microcontroller to the SPI pins.