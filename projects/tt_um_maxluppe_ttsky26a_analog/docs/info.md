<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements five different analog comparators based on standard logic cells. The analog inputs a[0] and a[1] are connected to the inputs V+ and V- of the comparators. Four comparators need an external clock signal, which is selected by the configuration tool.

## How to test

Insert a constant signal to one of the analog input (V-) and a variable signal to the other analog input (V-). Observe the output. If V+ > V- is expected the output OutP_comp set to '1' and OutM_comp to '0'.

## External hardware

It's necessary a signal generator to generate the analog input values (an[0] and an[1]) and an osciloscope to visualize both the inputs and the outputs from the comparators.
