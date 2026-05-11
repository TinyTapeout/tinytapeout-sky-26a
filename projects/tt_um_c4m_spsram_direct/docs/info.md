## How it works

This design contains a single port SRAM block with pins connected directly to TT tile pins. This allows to use this design directly as a SRAM block.

The included block has 128 words of 8 bits. These are the pins for the block:

* a (7 bit): address
* we (1 bit): write enable signal indicating a read or write operation
* d (8 bit): input data
* q (8 bit): output data
* clk: clock for performing an operation

On each rising edge of the clock an operation is performed on the memory. A read is done when `we` is 0, while a write operation is done when it is 1. On the rising edge of the clock the `a` and `d` signals are latched into an internal buffer. For a read operation the data for the provided address is put into the `q` signal, the `d` signal is ignored. For a write operation the value of the `d` signal is put in the given address. The write operation is write-through meaning that also `q` will get the value of `d` during the operation.

## How to test

You can test the block yourself by providing the right inputs for a read or write operation. One can check if data written to a certain location is later on read back with a read operation on the same address.
