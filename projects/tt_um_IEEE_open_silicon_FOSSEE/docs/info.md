## How it works

This project implements a 3-stage current-starved ring VCO designed in the SkyWater Sky130 130nm open-source PDK. The oscillator core uses PMOS current-source loads and NMOS tail-current sources controlled by a single control voltage (Vctrl). By varying Vctrl, the current through each delay stage is starved or boosted, directly tuning the oscillation frequency. A two-stage CMOS output buffer ensures rail-to-rail swing and isolates the oscillator core from external capacitive loading. The VCO achieves a tuning range of approximately 5.27 MHz to 57.57 MHz across Vctrl = 0.7V to 1.7V.

## How to test

1. Set VDD = 1.8V (nominal supply).
2. Sweep Vctrl from 0.7V to 1.7V in 0.1V steps.
3. Measure oscillation frequency at the buffered output — expected range ~5 MHz to ~57 MHz.
4. Verify frequency vs. Vctrl matches the characterization table (TT corner, 27°C).
5. For corner verification, repeat at FF (−40°C) and SS (85°C) conditions.
6. Optionally load the output with 10 fF (logic load) or 50 fF (buffer load) to verify load isolation.

## External hardware

No external hardware required. The design is a standalone analog VCO core intended for pre-layout simulation using Xschem + ngspice with the Sky130 PDK. No PMOD or external display interfaces are used.
