# CNN Hardware Accelerator – SystemVerilog Implementation

<p align="center">
  <img src="docs/Diagrams/logo.jpg" alt="Project Logo" width="180">
</p>

**Developed by:** Abdullah Nadeem & Talha Ayyaz  
**Organization:** [Maktab-e-Digital Systems Lahore](https://github.com/meds-uet)  
**License:** [Apache License 2.0](LICENSE)  
**Date:** July–August 2025  

---

## Overview  

The CNN Hardware Accelerator is a SystemVerilog-based implementation of a Convolutional Neural Network (CNN) designed for FPGA and ASIC deployment.  
It performs convolution, ReLU, max pooling, flattening, GAP, and argmax operations in dedicated hardware to deliver real-time image inference performance for embedded and edge AI systems.

*A modular, parameterized, and pipelined CNN accelerator optimized for speed, area, and reusability.*

---

## Top-Level Architecture  

<p align="center">
  <img src="docs/Diagrams/Top_CNN.png" alt="System-level CNN Accelerator pipeline" width="600">
  <br>
  <em>Figure: System-level CNN Accelerator pipeline.</em>
</p>


**Data Flow:**  
```
Input → Convolution + ReLU → Max Pooling → Flatten → GAP → Argmax → Output
```

---

## Key Features  

- Parameterizable design: configurable image size, kernel, stride, and bit-width  
- High performance with MAC units for real-time operation  
- Global Average Pooling (GAP) for compact feature vector generation  
- Modular and reusable RTL: each block as a standalone SystemVerilog module  
- Argmax layer for hardware classification output  
- Verified testbench with image-based functional tests and simulation waveforms  

---

## Quick Links  

| Resource | Badge / Link |
|-----------|---------------|
| Documentation | [![Docs](https://img.shields.io/badge/ReadTheDocs-Active-blue)](https://cnn-accelerator-docs.readthedocs.io/en/latest/) |
| License | [![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE) |
| Repository | [GitHub: meds-uet/CNN-Accelerator](https://github.com/meds-uet/CNN-Accelerator) |

---

## Getting Started  

Clone the repository and run the sample simulation:

```bash
# 1. Clone
git clone https://github.com/meds-uet/CNN-Accelerator.git
cd CNN-Accelerator

# 2. Build / simulate (using ModelSim)
make sim

# 3. Run testbench
vsim -do test/cnn_tb.do
```

**Expected Output:**
```
[INFO] Convolution + ReLU done
[INFO] MaxPooling done
[INFO] ofmap saved
```

---

## Core RTL Modules  

| Module | Function |
|--------|-----------|
| `conv.sv` | 2D Convolution + ReLU |
| `mac.sv` | Multiply–Accumulate Unit |
| `maxpool.sv` | 2×2 Max Pooling |
| `comparator.sv` | Max-of-4 Comparator |
| `flatten.sv` | Flatten 2D → 1D |
| `gap.sv` | Global Average Pooling |
| `argmax.sv` | Classification Index Output |
| `cnn_accelerator.sv` | Top-Level Integration |
| `cnn_defs.svh` | Global Parameters |

---

## Performance Snapshot  

| Operation | Latency | Notes |
|------------|----------|-------|
| Convolution | `O(CONV_OFMAP²)` | Parallel MAC pipeline |
| MaxPooling | `O(POOL_OFMAP²)` | 3-stage comparator logic |
| Throughput | 1 result/cycle | Fully pipelined design |
| Precision | 8–16 bits | Configurable via `cnn_defs.svh` |

---

## Requirements  

- Simulation Tools: ModelSim, QuestaSim or Vivado Simulator  
- Synthesis Tools: Xilinx Vivado  
- Python Utilities: For image preprocessing  

```python
from PIL import Image
import numpy as np
img = Image.open("input.png").convert('L').resize((256,256))
pixels = np.array(img, dtype=np.uint8)
```

---

## Future Enhancements  

- [ ] Multi-channel convolution  
- [ ] Bias and quantized layers (INT4/INT2)  
- [ ] AXI / DMA interfaces  
- [ ] Dynamic pooling sizes  
- [ ] Power-optimized variants  
- [ ] Fully connected (dense) layer integration  

---

## Repository Structure  

```
cnn_accelerator/
├── rtl/
│   ├── cnn_accelerator.sv
│   ├── conv.sv
│   ├── mac.sv
│   ├── maxpool.sv
│   ├── comparator.sv
│   ├── flatten.sv
│   └── cnn_defs.svh
├── test/
│   ├── cnn_tb.sv
│   └── imgs/
├── docs/
│   └── index.md
├── scripts/
│   ├── pgmToTxt.sh
│   └── txtToPng.py
├── makefile
└── LICENSE
```

---

## Full Documentation  

**Read the full technical documentation on ReadTheDocs:**  
[https://cnn-accelerator.readthedocs.io](https://cnn-accelerator.readthedocs.io)

---

## Credits  

- **Abdullah Nadeem** — System Architecture & RTL Implementation  
- **Talha Ayyaz** — Verification & Optimization  
- **Organization:** Maktab-e-Digital Systems Lahore  

---

## License  

Licensed under the **Apache License 2.0**.  
See [LICENSE](LICENSE) for full details.

---
