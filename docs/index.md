# CNN Accelerator – System Verilog HDL Implementation

**Developed by:** Abdullah Nadeem & Talha Ayyaz\
**License:** Apache License 2.0\
**Date:** July/August 2025

---

## Overview

This project implements a **Convolutional Neural Network (CNN) Accelerator** using **SystemVerilog**, designed to run basic CNN operations in hardware. It includes modules for **convolution**, **ReLU activation**, **max pooling**, and **flattening**. The design is modular and reusable, aiming to support efficient CNN inference on FPGA or ASIC platforms.

---

## Why This Project Matters

Software-based CNNs are powerful but often slow for edge devices. A **hardware accelerator** speeds up operations like convolution and pooling, making CNNs usable in real-time applications such as:

- Image recognition
- Object detection
- Video processing
- Embedded AI systems

---

## What Is a CNN Accelerator?

A **CNN accelerator** is a specialized hardware system designed to execute convolutional neural network computations faster and more efficiently than general-purpose processors. It achieves this by:

- Using **parallel computation units** like MACs (Multiply-Accumulate units)
- Implementing **convolution, pooling, and activation** in hardware
- Minimizing memory access delays by using local buffers or registers

These accelerators significantly reduce latency and power usage, making them ideal for embedded and real-time systems.

---

## Project Structure

### Top-Level Module

#### `cnn_accelerator.sv`

This is the **main module** that connects all the individual components together:

- Accepts an input feature map and kernel (filter)
- Performs convolution
- Applies **ReLU activation**
- Applies **2x2 max pooling**
- Outputs the final feature map

**Inputs:**

- Clock, reset, and enable signals
- Unsigned input image  (`cnn_ifmap`)
- Signed kernel weights

**Outputs:**

- Unsigned pooled output (`cnn_ofmap`)
- `done` signal indicating processing is complete

---

## Core Modules

### 1. `conv.sv` – Convolution Layer

Performs the **2D convolution** between the input feature map and kernel:

- Supports **padding** and **stride**
- Includes **ReLU activation** (sets negative results to zero)
- Uses a **MAC unit** to compute the sum of element-wise multiplications
- Controlled by a simple **Finite State Machine (FSM)**

**Performance Note:** The latency for the MAC/Convolution operation on a **6x6 input** is approximately **360 picoseconds**, which is significantly faster than equivalent software implementations in Python, C++, or MATLAB. While high-level languages may take microseconds or milliseconds due to sequential execution and software overhead, SystemVerilog enables **parallelism and clock-level control**, providing a much lower-latency, hardware-accelerated solution.

### 2. `mac.sv` – Multiply-Accumulate (MAC) Unit

- Takes two `KERNEL_SIZE x KERNEL_SIZE` matrices:
  - **Feature window** (unsigned)
  - **Kernel weights** (signed)
- Outputs the **accumulated dot product**
- Internally handles bit-width and signed multiplication

### 3. `maxpool.sv` – Max Pooling Layer

Applies **2x2 max pooling** with stride 2:

- Reduces the size of the feature map by selecting the **maximum value** in every 2x2 block
- Uses a **comparator module** to find the max
- Also uses a state machine for control

### 4. `comparator.sv` – 2x2 Max Comparator

Takes four `DATA_WIDTH` size unsigned inputs and returns the **maximum**. Used in max pooling.

### 5. `flatten.sv` – Flattening Layer

Converts the 2D pooled feature map into a **1D vector**:

- Required before passing data to fully connected layers in CNNs
- Preserves spatial order using row-major flattening

---

## Global Parameters

Defined in `cnn_defs.sv`:

- `DATA_WIDTH`: Bit width of each pixel or weight (set to 8 bits for 0-255 **greyscale pixel range**)  
- `IFMAP_SIZE`: Input feature map size (for testing : 128x128)  
- `KERNEL_SIZE`: Size of convolution kernel (default: 3x3 or 5x5)  
- `STRIDE`, `PADDING`: Stride and zero-padding for convolution  

Derived parameters include:

- `CONV_OFMAP_SIZE`: Output size after convolution  
- `POOL_OFMAP_SIZE`: Output size after 2x2 pooling  
- `MAC_RESULT_WIDTH`: Bit-width of MAC result based on kernel size and pixel depth  
- FSM state definitions: Control logic for `conv` and `pool` modules  

These parameters make the design **easily configurable**  for different CNN sizes and hardware constraints.

---

## How It Works – Data Flow

This CNN accelerator performs the standard operations in a forward pass of a convolutional neural network. Below is a breakdown of how data flows through each stage:

1. **Convolution:**

   - The input feature map (`cnn_ifmap`) is a 2D image represented as a matrix of pixel values.
   - A convolution window of size `KERNEL_SIZE x KERNEL_SIZE` slides over the input matrix with a defined `STRIDE` and optional `PADDING`.
   - At each position, corresponding input pixels and kernel weights are multiplied and summed using a **MAC (Multiply-Accumulate)** unit.
   - The sum is passed through a **ReLU (Rectified Linear Unit)** function, which sets all negative outputs to zero, introducing non-linearity.
   - The result is stored in the **convolution output feature map**, whose dimensions depend on the stride, padding, and kernel size.

2. **Max Pooling:**

   - The convolution output is fed into the **maxpool module**, which performs 2x2 non-overlapping window scans.
   - For each 2x2 block, the **maximum value** is selected using the `comparator` module.
   - This reduces the spatial resolution (typically by a factor of 2), keeping the most prominent features and reducing computation in subsequent layers.
   - The result is the **pooled feature map**, a downsampled version of the convolution output.

3. **Flatten (Optional):**

   - The 2D pooled output matrix is **flattened** into a 1D vector using row-major order.
   - This is often necessary before feeding the output into **fully connected (dense) layers**, which expect linear input.
   - The flattening process maintains the spatial ordering so that feature information is preserved.

Each stage is controlled using FSMs (Finite State Machines), enabling synchronization, data reuse, and high throughput under a clocked design.

---

## Use Cases

- FPGA/ASIC CNN acceleration
- RTL simulation and verification of CNNs
- Learning project for digital design and SystemVerilog

---

## How to Use

1. Set desired parameters in `cnn_defs.sv`
2. Instantiate `cnn_accelerator` in your testbench
3. Provide a valid `cnn_ifmap` and `weights`
4. Monitor `cnn_ofmap` and `done` signal

---

## Requirements

To simulate and verify the design:

### HDL Simulation:

- **ModelSim or QuestaSim** – Required to run simulations (`vsim` command)
- **SystemVerilog support** in simulator

### Python Pre/Post-processing :

Used for image preprocessing and verification:

```python
from PIL import Image
import numpy as np
```

These help in preparing input matrices and comparing output from simulation.

**Key Notes:**

- Make sure your simulator license supports SystemVerilog multidimensional arrays.
- Maintain consistent `DATA_WIDTH` across input preparation and RTL.
- Python tools can generate `cnn_ifmap` and `weights` as `.mem` or `.hex` files for loading into testbenches.

---

## Notes

- Currently supports **one convolution kernel** and **one image**
- Working on expanding this to:
  - Multiple kernels (for multiple channels)
  - Bias addition
  - Fully connected layers
  - Batch processing
- Max pooling operation is **non-configurable** (set to 2x2) since it is most efficent and used in 2 x 2 pooling
- Input kernel is **unsigned** due to pixel values ranging from 0 - 255 (in a greyscale image)
---

## License

This project is licensed under the **Apache License 2.0**.\
See the LICENSE file for more details.

---

## Credits

Developed by:

- Abdullah Nadeem
- Talha Ayyaz\
  **Maktab-e-Digital Systems, Lahore – July/August 2025**

