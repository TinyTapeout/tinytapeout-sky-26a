## How it works

This project implements a **CA-CFAR (Cell Averaging Constant False Alarm Rate) radar detector** with a buzzer alert output.

Radar samples are provided through the input bus `ui_in[7:0]`. These samples represent signal amplitudes from a radar or sensing system such as Ground Penetrating Radar (GPR) or object detection sensors.

The CFAR algorithm processes the samples using a **sliding window structure**:

Training Cells | Guard Cells | CUT | Guard Cells | Training Cells

Training cells estimate the background noise level. Guard cells prevent the target signal from influencing the noise estimate. The **Cell Under Test (CUT)** is the sample being evaluated for detection.

The noise level from the surrounding training cells is averaged and used to generate a dynamic threshold:

threshold = 2 × average_noise

If the CUT value exceeds this threshold, a target detection event is generated.

Outputs of the design:

* `uo_out[0]` – CFAR detection signal
* `uo_out[1]` – buzzer output signal

When a detection occurs, the buzzer module produces an alert signal indicating the presence of a detected target.

## How to test

The design can be simulated using **Icarus Verilog**.

Compile the design:

```
iverilog -o sim src/*.v test/tb.v
```

Run the simulation:

```
vvp sim
```

Open the waveform viewer:

```
gtkwave tb.fst
```

Example radar input sequence used for testing:

```
10 11 9 10 12 11 10 200 11 10
```

In this sequence, the value **200** represents a strong reflection and should exceed the CFAR threshold. When this happens, the detection output (`uo_out[0]`) becomes high and the buzzer output (`uo_out[1]`) is activated.

## External hardware

No external hardware is required.

The project is fully digital and designed to run inside the TinyTapeout ASIC environment. For real-world applications, the output pins could be connected to external devices such as a buzzer, LED indicator, or radar front-end module.
