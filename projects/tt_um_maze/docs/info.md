<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a maze generator game. It puts any maze from any size up to the contraint.
It works by executing the ellers algorithm. Quite simple generator for mazes.
Is based on the concepts of the following article:
https://weblog.jamisbuck.org/2010/12/29/maze-generation-eller-s-algorithm


The full featured version includes the actual maze generator in RTL.
Now, due to restrictions in size, this algorithm is not featured in the smaller versions.

As stated in the README.md: If you want another size (with more features), you can:

- Change the `info.yaml`
- Change the `src/maze.v` and define/undefine `ULTRA_SMALL_1x1` in line `78`.

## How to test

You can visualize it using the vga-playgrond. If you want to do it locally:

```bash
make -C test playground
```

You can run basic simulations. However, there isn't anything automated:

```bash
cd test && make -B
gtkwave tb.fst
```

## External hardware

This repository uses the following hardware:
- PMOD Gamepad
- PMOD VGA
