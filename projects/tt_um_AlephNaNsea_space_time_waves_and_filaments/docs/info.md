## How it works

"Space-Time Waves and Filaments" is a purely combinatorial generative hardware video synthesizer written in Verilog. It calculates continuously evolving procedural art in real-time for a 640x480 VGA display at 60Hz.

The design features a custom VGA sync engine that drives a screen-space coordinate system. By treating the center of the screen (320, 240) as the geometric origin, the hardware generates perfectly symmetrical patterns using absolute distances (`cx`, `cy`) and octagonal approximations.

Instead of relying on RAM or expensive DSP blocks for sines and cosines, the visual engines rely entirely on bitwise operations (like XOR fractals) and moving triangle waves. An internal frame counter acts as the flow of "time," continuously shifting the geometry and color palettes to create a smooth 60fps animation. 

To fit the incredibly complex mathematical structures within the strict routing density limits of the Tiny Tapeout ASIC tile, the design employs a targeted "Math Diet." Engines 0 through 4 utilize high-resolution 10-bit math for perfectly smooth visuals, while Engine 5 intentionally downscales its coordinate space to 6-bit logic. This drastically reduces the physical logic gate count, freeing up routing space while generating a uniquely chunky, retro 16x16 macroblock aesthetic.

A multiplexer routes one of six mathematical art engines to the output based on the state of the input pins:
* **Default:** The Cosmic Web "Black Hole" (A rotational XOR fractal)
* **Engine 1 (`ui_in[0]`):** Rolling Ocean Waves (Interfering pseudo-sine waves)
* **Engine 2 (`ui_in[1]`):** Red, White, & Blue Spider Web (Distance-based geometric spokes and rings)
* **Engine 3 (`ui_in[2]`):** The Centered Tunnel (A collapsing XOR geometry)
* **Engine 4 (`ui_in[3]`):** Detailed Qubit Entanglement (A high-frequency, counter-rotating Sierpinski probability field simulating quantum interference)
* **Engine 5 (`ui_in[4]`):** Super Low-Res Digital Tempest (A chaotic whirlpool rendered in 16x16 macroblocks)

## How to test

To test the synthesizer, you will need to provide a standard 25.175 MHz clock to drive the VGA timing correctly. 

1. Connect a VGA monitor to the output pins via a standard Tiny VGA PMOD (or an equivalent resistor-ladder DAC).
2. Apply the 25.175 MHz clock and reset the design. You should immediately see the default **Cosmic Web** animation on the screen.
3. Use the input pins to toggle between the different generative modes:
    * **Toggle `ui_in[0]` HIGH:** Displays the Rolling Ocean Waves.
    * **Toggle `ui_in[1]` HIGH:** Displays the Red, White, and Blue Spider Web.
    * **Toggle `ui_in[2]` HIGH:** Displays the Centered Tunnel.
    * **Toggle `ui_in[3]` HIGH:** Displays the Detailed Qubit Entanglement.
    * **Toggle `ui_in[4]` HIGH:** Displays the Super Low-Res Digital Tempest.
    * *(Note: The inputs have a built-in strict priority. `ui_in[4]` will override `ui_in[3]`, which overrides `ui_in[2]`, and so on down the chain.)*

## External hardware

* **Tiny VGA PMOD** (or compatible 3-bit-per-channel R2R DAC).
* A standard VGA cable and a monitor capable of supporting 640x480 resolution at 60Hz.
* 5 DIP switches or buttons connected to the first five input pins (`ui_in[4:0]`) to change the visual modes.
