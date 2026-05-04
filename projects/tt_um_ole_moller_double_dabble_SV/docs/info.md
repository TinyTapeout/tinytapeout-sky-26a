## How it works

The double_dabble main module converts 8-bit binary numbers to decimal numbers displayed on a 7-segment display as sequences of 3 BCD digits separated by a decimal point. If the binary number is changed the conversion will start over.

The conversion is done with the Double Dabble algoritm where each of the 8 loop iterations uses a 12-bit register that can hold 3 groups of 4 bits (that will later become the BCD digits) to implements the core part of the algoritm, which shifts all 12 bits to the left and injects the next bit from the input, and then for each group of 4 bits adds the value 3 (binary 0011) if the value of the group is 5 (binary 0101) or above. Adding 3 before the left shift corresponds to adding 6 after the shift, which in effect generates a carry into the next group of 4 bits, and ensures that the value of present group always be in the range 0 to 9. Note that 6 is the difference between the greatest hexadecimal and decimal digits, A = 15 and 9, respectively.

The conversion is implemented by combinational logic that unrolls the loop above, while presentation of the decimal result is implemented with a state machine that sequentially displays hundreds, tens, ones, and finally a decimal point before starting over. Note that the generic unrolling means that some of the bits of the vector temp_bcd will not be used resulting in a warning during elaboration.

The device has an 8-bit input for the binary number, an 8-bit output for the 7-segment display with decimal point, and an 8-bit bidirectional port that always outputs the tens and the ones from the conversion. This comes for free and is part of the testing.

The lowest external clock is 1 Hz and by dividing it by 4 allows ample time to observe the output on the 7-segment display. The reset signal ensures that the divided clock starts low and that the state machine for presenting the decimal result starts with a decimal point.

## How to test

Check whether any 8-bit binary number is displayed correctly on the 7-segment display as a time sequence of digits (hundreds, tens, and ones) followed a decimal point as separator. The decimal numbers 0, 12, 77, 167, 189, 243, and 255 have been tested in the test vectors.

## External hardware

Nothing 
