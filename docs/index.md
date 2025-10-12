# CNN Hardware Accelerator - SystemVerilog Implementation

**Developed by:** Abdullah Nadeem & Talha Ayyaz  
**Organization:** Maktab-e-Digital Systems Lahore  
**License:** Apache License 2.0  
**Date:** July/August 2025

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

## Abstract

This project presents a complete hardware implementation of a Convolutional Neural Network (CNN) accelerator using SystemVerilog HDL. The design features modular components for convolution, ReLU activation, max pooling, and flattening operations, optimized for FPGA and ASIC deployment. The accelerator achieves significant performance improvements over software implementations. The design supports configurable parameters and includes real-image testbench demonstrations.

---

## How the CNN Accelerator Works

At a high level, the CNN accelerator mimics the structure of a typical convolutional neural network in hardware. It operates on grayscale image inputs and processes them through several dedicated hardware blocks:

1. **Convolution + ReLU Block**
   Applies a sliding window 3×3 kernel to the input image, performing multiply-accumulate (MAC) operations to extract features. The result is passed through a ReLU activation function to zero out negative values.

2. **Max Pooling Block**
   Reduces the spatial dimensions of the feature maps using 2×2 max pooling, helping to retain essential features while lowering computational load.

3. **Flatten Block**
   Converts the pooled 2D matrix into a 1D vector that can be directly fed into a classifier or fully connected layer in later stages.

4. **Global Average Pooling (GAP) Block**
   Computes the average of each feature map to produce a compact 1D representation, reducing parameters and hardware complexity.

5. **Argmax Block**
   Identifies the index of the maximum value in the GAP output, providing the predicted class for classification tasks.

Each operation is fully pipelined and controlled using finite state machines (FSMs) to ensure efficient and parallel execution. The design is parameterized and reusable, making it suitable for both FPGA prototyping and ASIC flows.

**Top-Level Flow:**

```
Input → Convolution + ReLU → Max Pooling → Flatten → GAP → Argmax → Output
```

**Benefits:**

* Reduces parameter count.
* Efficient hardware implementation.
* Suitable for real-time embedded classification tasks.


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

![Figure 1: Top Level Diagram](Diagrams/Top_CNN.png)

---

## Core Modules

### 1. Convolution Module (`conv.sv`)

Applies a 2D convolution and ReLU activation.

**Key Features:**
- Sliding window convolution  
- Zero-padding and stride control  
- ReLU activation built-in  
- FSM-based operation  

![Figure 2: Convolution Diagram](Diagrams/Conv.png)

---

### 2. MAC Unit (`mac.sv`)

Optimized multiply-accumulate logic for convolution.

**Highlights:**
- Parallel multipliers  
- Adder tree  
- One-cycle accumulation  

![Figure 3: MAC unit architecture (multipliers + adder tree)](Diagrams/MAC.png)

---

### 3. MaxPooling Module (`maxpool.sv`)

Performs 2×2 max pooling with stride 2.

**Key Features:**
- 2×2 window extractor  
- 3-stage comparator logic  
- FSM-controlled state machine  

![Figure 4: Maxpool Diagram](Diagrams/Maxpool.png)

---

### 4. Comparator Unit (`comparator.sv`)

Selects the maximum of a 2×2 input.

**Highlights:**
- Three comparator stages  
- Single-cycle output  
- Unsigned input handling  

![Figure 5: Comparator logic to extract max from 4 inputs](Diagrams/Comparator.png)

---

### 5. Flatten Module (`flatten.sv`)

Converts 2D pooled maps to 1D vectors.

**Features:**
- Row-major flattening  
- Output ready for fully connected layers  

![Figure 6: Flatten Diagram](Diagrams/Flatten.png)

## 6. Global Average Pooling (GAP) Module

The **Global Average Pooling (GAP)** layer is a lightweight alternative to fully connected layers. Instead of flattening the feature maps and connecting them to dense layers, GAP computes the **average value of each feature map**. This reduces the number of parameters and helps prevent overfitting while maintaining spatial information.

### Features

* Computes the average of each 2D feature map.
* Produces a 1D vector with a length equal to the number of channels.
* Fully pipelined for hardware efficiency.
* Output directly suitable for classification layers.

### Operation

1. Accumulate all pixel values in a feature map.
2. Divide by the total number of pixels (`IFMAP_SIZE × IFMAP_SIZE`).
3. Output a single value per feature map.

**FSM States:**
`IDLE → ACCUMULATE → DIVIDE → DONE`

**Signal Descriptions:**

| Signal           | Width              | Description                   |
| ---------------- | ------------------ | ----------------------------- |
| `clk`            | 1                  | Clock                         |
| `reset`          | 1                  | Active-high async reset       |
| `en`             | 1                  | Start signal                  |
| `feature_map_in` | `[DATA_WIDTH-1:0]` | Input feature map             |
| `gap_out`        | `[DATA_WIDTH-1:0]` | Output vector after averaging |
| `done`           | 1                  | Completion flag               |

---

## 7. Argmax Module

The **Argmax** module identifies the index of the maximum value in a 1D vector. This is commonly used in classification tasks to select the predicted class with the highest probability.

### Features

* Accepts the 1D vector output from GAP or flatten layer.
* Returns the **index** corresponding to the largest value.
* Single-cycle comparator logic for small vectors; pipelined for large vectors.
* Compatible with fixed-point or integer data.

### Operation

1. Initialize `max_val` and `max_idx` to zero.
2. Compare each element sequentially (or in a tree structure for large vectors).
3. Update `max_val` and `max_idx` when a larger value is found.
4. Output the final `max_idx` as the predicted class.

**FSM States:**
`IDLE → COMPARE → DONE`

**Signal Descriptions:**

| Signal       | Width                       | Description             |
| ------------ | --------------------------- | ----------------------- |
| `clk`        | 1                           | Clock                   |
| `reset`      | 1                           | Active-high async reset |
| `en`         | 1                           | Start signal            |
| `vector_in`  | `[DATA_WIDTH-1:0]`          | Input 1D vector         |
| `argmax_out` | `[$clog2(VECTOR_SIZE)-1:0]` | Index of the max value  |
| `done`       | 1                           | Completion flag         |


---

## Global Parameters

Defined in `cnn_defs.svh`:

| Parameter | Standard Value | Description |
|----------|--------|-------------|
| `DATA_WIDTH` | 8            | Bit width of input/weights |
| `IFMAP_SIZE` | Configurable | Input image size |
| `KERNEL_SIZE` | 3×3 or 5x5  | Convolution kernel size |
| `STRIDE` | 1 or 2 | Step size |
| `PADDING` | 1 or 2 | Zero-padding |

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
| MAC Latency | Platform dependent | Synthesized for FPGA/ASIC |

---

## Testbench Results

### Input Image
![Figure: Original grayscale image, 256×256](Diagrams/InputOP.png)

### Convolution Output
![Figure: After 3x3 Laplacian convolution and ReLU](Diagrams/ConvOP.png)

### MaxPooling Output
![Figure: After 2x2 max pooling (downsampled to 128×128)](Diagrams/maxpoolOP.png)

---

## Usage Guidelines

### Configuration

Each module in the CNN accelerator is parameterized to support different image sizes, kernel configurations, and arithmetic precision. You can modify the parameters globally by editing the `cnn_defs.svh` file, or locally during module instantiation.

**Common Parameters:**

| Parameter | Description |
|-----------|-------------|
| `DATA_WIDTH` | Bit width for pixel and weight data (e.g., 8 for 8-bit inputs) |
| `IFMAP_SIZE` | Size of the input feature map (e.g., 128 for 128×128 images) |
| `KERNEL_SIZE` | Size of the convolution kernel (typically 3) |
| `STRIDE` | Step size used in convolution or pooling |
| `PADDING` | Zero-padding around the input feature map |
| `MAC_RESULT_WIDTH` | Bit width of the MAC output accumulator |

**Example: Modifying Parameters in `cnn_defs.svh`**
```systemverilog
parameter int DATA_WIDTH        = 8;
parameter int IFMAP_SIZE        = 256;
parameter int KERNEL_SIZE       = 3;
parameter int STRIDE            = 1;
parameter int PADDING           = 1;
```

Adjusting these parameters will automatically scale the functionality and resource usage of the modules accordingly.

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
│ 
├── scripts/
│   ├── pgmToTxt.sh
│   └── txtToPng.py
│
├── makefile 
```

---

## License

Licensed under the **Apache License 2.0**.  
See [LICENSE](LICENSE) for full terms.

---

## Credits

- **Abdullah Nadeem** — System Architecture & RTL Implementation  
- **Talha Ayyaz** — Verification & Optimization  

---

## Contact

**Maktab-e-Digital Systems Lahore**  
Lahore, Punjab, Pakistan  
[GitHub Repository Link](https://github.com/meds-uet/CNN-Accelerator)

---

*This project is a practical, hardware-level implementation of CNN inference designed for FPGAs.*