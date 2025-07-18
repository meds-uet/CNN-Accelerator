# Convolutional Neural Network (CNN) Architecture

This project includes a CNN (Convolutional Neural Network) written in **SystemVerilog**.
It is built for simulation and testing image classification logic in hardware design.

---

##  File Overview

```bash
CNN-ACCELERATOR/
├── rtl/
│   ├── cnn_defs.svh
│   ├── cnn_accelerator.sv
│   ├── conv.sv
│   ├── mac.sv
│   ├── maxpool.sv
│   ├── comparator.sv
│   ├── flatten.sv
│
├── scripts/
│   ├── pgmToTxt.py
│   ├── txtToPng.py
│
├── test/
│   ├── cnn_tb.sv
│   └── img/
│       ├── image2.png
│       └── ...
│  
│
└── README.md

```

---

##  How the CNN Works

This CNN Architecture consists of `6 modules` with `1 header file`. The CNN hardware implementation follows a sequence. The image is converted into a txt file so it can be read by the HDL, the txt file is then sent to the `SV` implementation where it is `Convoluted` using `MAC Adder Tree` then `Max Pooled` and `flattened` to give an `1D Array`   

1. **Input Image**
   - The image is given to the CNN Architecture as pixel data `grayscale`.

2. **Convolution Layer**
   - This layer looks at small parts of the image.
   - It uses filters (like a small window) to find patterns like edges or shapes.
---

##  Project Notes

- Written in SystemVerilo
- Designed to simulate a basic CNN architecture


---

##  Requirements

- ModelSim or Verilator (to compile and run)
- GTKWave (to view `.vcd` waveform output)
- Make (for build automation)


---

