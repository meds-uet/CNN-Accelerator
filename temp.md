
# CNN Hardware Accelerator - SystemVerilog Implementation

**Developed by:** Abdullah Nadeem & Talha Ayyaz  
**Organization:** Maktab-e-Digital Systems Lahore  
**License:** Apache License 2.0  
**Date:** July/August 2025

---

## Abstract

This project presents a complete hardware implementation of a Convolutional Neural Network (CNN) accelerator using SystemVerilog HDL. The design features modular components for convolution, ReLU activation, max pooling, and flattening operations, optimized for FPGA and ASIC deployment. The accelerator achieves significant performance improvements over software implementations, with convolution operations completing in approximately 360 picoseconds. The design supports configurable parameters and includes real-image testbench demonstrations.

---

## Table of Contents

- [Why This Project Matters](#why-this-project-matters)
- [What Is a CNN Accelerator?](#what-is-a-cnn-accelerator)
- [Architecture Overview](#architecture-overview)
- [Core Modules](#core-modules)
- [Global Parameters](#global-parameters)
- [Data Flow and Operation](#data-flow-and-operation)
- [Signal Descriptions](#signal-descriptions)
- [Performance Characteristics](#performance-characteristics)
- [Testbench Results](#testbench-results)
- [Usage Guidelines](#usage-guidelines)
- [Requirements](#requirements)
- [Future Enhancements](#future-enhancements)
- [License](#license)
- [Credits](#credits)
- [Contact](#contact)

---

## Why This Project Matters

Software-based CNNs are powerful but too slow for edge devices and real-time applications. A **hardware accelerator** dramatically speeds up operations like convolution and pooling, making CNNs viable for:

- Real-time image recognition and classification  
- Object detection in autonomous systems  
- Video processing pipelines  
- Embedded AI systems  
- Edge computing

---

## What Is a CNN Accelerator?

A CNN accelerator is custom hardware optimized to compute CNN operations efficiently using:

- Parallel MAC (multiply-accumulate) units  
- Local memory buffers  
- FSM-driven pipelines  
- ReLU and pooling operations in hardware  

Ideal for fast, low-power inference on embedded platforms.

---

## Architecture Overview

### Top-Level Module: `cnn_accelerator.sv`

Orchestrates the entire CNN pipeline:

**Flow:**  
`Input → Convolution + ReLU → Max Pooling → Flatten → Output`

**Image:**  
![Top-Level Accelerator Flow](docs/images/top_level_block.png)

---

## Core Modules

### 1. Convolution Module (`conv.sv`)

Applies a 2D convolution and ReLU activation.

**Key Features:**
- Sliding window convolution  
- Zero-padding and stride control  
- ReLU activation built-in  
- FSM-based operation  

**Image Example:**
![Convolution Output](docs/images/conv_output_256.png)

> *Figure: Convolution result (256×256) using Laplacian filter with ReLU activation*

---

### 2. MAC Unit (`mac.sv`)

Optimized multiply-accumulate logic for convolution.

**Highlights:**
- Parallel multipliers  
- Adder tree  
- One-cycle accumulation  

**Image Example:**
![MAC Operation](docs/images/mac_unit_diagram.png)

> *Figure: MAC unit architecture (multipliers + adder tree)*

---

### 3. MaxPooling Module (`maxpool.sv`)

Performs 2×2 max pooling with stride 2.

**Key Features:**
- 2×2 window extractor  
- 3-stage comparator logic  
- FSM-controlled state machine  

**Image Example:**
![MaxPooling Output](docs/images/maxpool_output_128.png)

> *Figure: MaxPool result (128×128), half the resolution of convolution output*

---

### 4. Comparator Unit (`comparator.sv`)

Selects the maximum of a 2×2 input.

**Highlights:**
- Three comparator stages  
- Single-cycle output  
- Unsigned input handling  

**Image Example:**
![Comparator Block](docs/images/comparator_unit.png)

> *Figure: Comparator logic to extract max from 4 inputs*

---

### 5. Flatten Module (`flatten.sv`)

Converts 2D pooled maps to 1D vectors.

**Features:**
- Row-major flattening  
- Output ready for fully connected layers  

**Image Example:**
![Flatten Output](docs/images/flatten_output_vector.png)

> *Figure: Flattened 1D vector from 128×128 pooled output*

---

## Global Parameters

Defined in `cnn_defs.svh`:

| Parameter | Value | Description |
|----------|--------|-------------|
| `DATA_WIDTH` | 8 | Bit width of input/weights |
| `IFMAP_SIZE` | 128×128 | Input image size |
| `KERNEL_SIZE` | 3×3 | Convolution kernel size |
| `STRIDE` | 1 or 2 | Step size |
| `PADDING` | 1 | Zero-padding |
| `MAC_RESULT_WIDTH` | 19 | MAC accumulator width |

---

## Data Flow and Operation

### Processing Pipeline

1. **Convolution + ReLU:** Extract windows → MAC → ReLU  
2. **Max Pooling:** 2x2 max selection → downsampling  
3. **Flatten:** 2D → 1D vector for classifier input  

**FSM States:**  
- `IDLE` → `PROCESSING` → `DONE`  

---

## Signal Descriptions

### Inputs

| Signal | Width | Description |
|--------|--------|-------------|
| `clk` | 1 | Clock |
| `reset` | 1 | Active-high async reset |
| `en` | 1 | Start signal |
| `cnn_ifmap` | `[DATA_WIDTH-1:0]` | Input image |
| `weights` | `[DATA_WIDTH-1:0]` | Convolution kernel |

### Outputs

| Signal | Width | Description |
|--------|--------|-------------|
| `cnn_ofmap` | `[DATA_WIDTH-1:0]` | Final output |
| `conv_ofmap` | `[DATA_WIDTH-1:0]` | After convolution |
| `pool_ofmap` | `[DATA_WIDTH-1:0]` | After pooling |
| `done` | 1 | Completion flag |

---

## Performance Characteristics

| Operation | Latency | Description |
|-----------|---------|-------------|
| Convolution | CONV_OFMAP² + 2 cycles | Parallel MAC with FSM |
| MaxPooling | POOL_OFMAP² + 2 cycles | 3 comparator stages |
| Throughput | 1 result/cycle | Fully pipelined |
| MAC Latency | ~360 ps | FPGA synthesized |

---

## Testbench Results

### Input Image
![Input Image](docs/images/input_256.png)  
*Figure: Original grayscale image, 256×256*

### Convolution Output
![Convolution Result](docs/images/conv_output_256.png)  
*Figure: After 3x3 Laplacian convolution and ReLU*

### MaxPooling Output
![MaxPool Result](docs/images/maxpool_output_128.png)  
*Figure: After 2x2 max pooling (downsampled to 128×128)*

### Final Flattened Output (Conceptual)
![Flattened Output](docs/images/final_flattened_output.png)  
*Figure: Flattened vector sent to fully connected layers*

---

## Usage Guidelines

### Configuration
```systemverilog
parameter DATA_WIDTH = 8;
parameter KERNEL_SIZE = 3;
parameter STRIDE = 1;
parameter PADDING = 1;
```

### Instantiation
```systemverilog
cnn_accelerator #(
  .DATA_WIDTH(8),
  .KERNEL_SIZE(3)
) cnn_inst (
  .clk(clk),
  .reset(reset),
  .en(enable),
  .cnn_ifmap(input_image),
  .weights(kernel_weights),
  .cnn_ofmap(output_result),
  .done(processing_done)
);
```

### Run Flow
```systemverilog
enable = 1;
wait (processing_done);
read_output(output_result);
```

---

## Requirements

- **Simulators:** ModelSim, QuestaSim, VCS, Vivado Simulator  
- **Synthesis:** Vivado, Quartus, Design Compiler  
- **Python Tools:** For image loading and testbench data generation

```python
from PIL import Image
import numpy as np

img = Image.open("input.png").convert('L').resize((256, 256))
pixels = np.array(img, dtype=np.uint8)
```

---

## Future Enhancements

- [ ] Multi-kernel/multi-channel support  
- [ ] Bias addition in convolution  
- [ ] Larger or dynamic pooling sizes  
- [ ] Fully connected layers  
- [ ] Quantization (INT4, INT2)  
- [ ] AXI interface & DMA  
- [ ] Power management  

---

## Project Structure

```
cnn_accelerator/
├── src/
│   ├── cnn_accelerator.sv
│   ├── conv.sv
│   ├── mac.sv
│   ├── maxpool.sv
│   ├── comparator.sv
│   ├── flatten.sv
│   └── cnn_defs.svh
├── testbench/
│   ├── tb_cnn_accelerator.sv
│   └── test_images/
├── docs/
│   ├── README.md
│   ├── architecture.md
│   └── images/
│       ├── input_256.png
│       ├── conv_output_256.png
│       ├── maxpool_output_128.png
│       ├── final_flattened_output.png
│       ├── comparator_unit.png
│       ├── mac_unit_diagram.png
│       ├── top_level_block.png
├── scripts/
│   ├── run_sim.sh
│   └── image_prep.py
```

---

## License

Licensed under the **Apache License 2.0**.  
See [LICENSE](LICENSE) for full terms.

---

## Credits

- **Abdullah Nadeem** — System Architecture & RTL Implementation  
- **Talha Ayyaz** — Verification & Optimization  

### Timeline:
- Conv Module: July 3, 2025  
- MAC & MaxPooling: July 14, 2025  
- Integration: July 29, 2025  

---

## Contact

**Maktab-e-Digital Systems Lahore**  
📍 Lahore, Punjab, Pakistan  
📧 *Contact info or repository link here*  
📁 *[GitHub Repository Link]*

---

*This project is a practical, hardware-level implementation of CNN inference designed for FPGAs and custom SoCs.*
