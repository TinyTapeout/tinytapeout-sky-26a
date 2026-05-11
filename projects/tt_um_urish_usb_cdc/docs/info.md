## How it works

A USB CDC to UART bridge, based on [tinyfpga_bx_usbserial](https://github.com/davidthings/tinyfpga_bx_usbserial).

## How to test

1. Connect `usb_p` and `usb_n` pins to D+ / D- USB pins either through 68 ohm resistors or directly (the resistors are recommended, but not mandatory).
2. Connect a 1.5k ohm resistor between `dp_pu_o` and `usb_p` (D+).
3. Connect the RX and TX pins to a UART device or to a logic analyzer.
4. Set the clock frequency to 48 MHz.

The device should appear as a serial port on your computer, with vendor_id=1209 and product_id=5454 (https://pid.codes/1209/5454/). The baud rate for the UART interface is hardcoded at 115200.

### Demo mode

Set `ui_in[0]` high to enable demo mode. In this mode, the device sends "Tiny Tapeout!" over USB once per second. UART RX input is ignored while demo mode is active.

## External Hardware

USB breakout board, 1.5k ohm resistor
