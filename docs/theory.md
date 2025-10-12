# Theory of Operation

The CNN accelerator performs typical deep learning operations — convolution, activation, pooling, and flattening — entirely in hardware.

## Data Flow

```
Input → Convolution + ReLU → MaxPooling → Flatten → GAP → Argmax → Output
```

## Architecture Overview

![Top-Level Diagram](Diagrams/Top_CNN.png)

The system is composed of the following key modules:

- **conv.sv:** Performs 2D convolution and ReLU activation  
- **mac.sv:** Core multiply-accumulate unit  
- **maxpool.sv:** 2×2 pooling with stride 2  
- **flatten.sv:** Converts feature maps into 1D vector  
- **gap.sv:** Global average pooling  
- **argmax.sv:** Classification output logic  
