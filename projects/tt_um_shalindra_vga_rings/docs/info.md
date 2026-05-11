<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The ring display uses the ui_in byte to set the speed and colours present in the rings. The bit description enables the following when enabled:


- ui_in[1:0] - speed select
- ui_in[2]: Reverse Direction
- ui_in[3]: Red Disable
- ui_in[4]: Green Disable
- ui_in[5]: Blue Disabled
- ui_in[7:6]: not used

## How to test

Simply just tie the relevant pins to toggle the relevant settings

## External hardware

VGA display and connecter will be required.
