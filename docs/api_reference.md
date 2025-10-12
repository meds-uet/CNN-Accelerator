# CNN Accelerator – API Reference

**SystemVerilog Implementation**  
**Developed by:** Abdullah Nadeem & Talha Ayyaz

---

## Top-Level Module: `cnn_accelerator`

**Description:**  
Integrates all sub-modules to form the complete CNN accelerator. Manages the flow of data through convolution, activation, pooling, flattening, GAP, and output logic.

**Ports:**

| Port          | Type                            | Description |
|---------------|--------------------------------|-------------|
| clk           | input logic                     | System clock |
| reset         | input logic                     | Active-high reset |
| en            | input logic                     | Enable signal |
| cnn_ifmap     | input logic [DATA_WIDTH-1:0][0:IFMAP_SIZE-1][0:IFMAP_SIZE-1] | Input feature map (unsigned) |
| weights       | input logic signed [DATA_WIDTH-1:0][0:KERNEL_SIZE-1][0:KERNEL_SIZE-1] | Convolution kernel weights |
| cnn_ofmap     | output logic [DATA_WIDTH-1:0][0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1] | Final output feature map |
| done          | output logic                    | Completion flag |

**Parameters:**

| Parameter    | Default | Description |
|-------------|---------|-------------|
| DATA_WIDTH  | 8       | Bit width of input and weights |
| IFMAP_SIZE  | 256     | Input feature map size |
| KERNEL_SIZE | 3       | Convolution kernel size |
| STRIDE      | 1       | Convolution/pooling stride |
| PADDING     | 1       | Convolution padding |
| NUM_CLASSES | 10      | Number of output classes |

---

## Sub-Modules

### `conv`
Performs 2D convolution with ReLU activation.

**Ports:**

| Port        | Type                                | Description |
|------------|------------------------------------|-------------|
| clk        | input logic                         | System clock |
| reset      | input logic                         | Reset |
| en         | input logic                         | Enable signal |
| conv_ifmap | input logic [DATA_WIDTH-1:0][0:IFMAP_SIZE-1][0:IFMAP_SIZE-1] | Input feature map |
| weights    | input logic signed [DATA_WIDTH-1:0][0:KERNEL_SIZE-1][0:KERNEL_SIZE-1] | Kernel weights |
| conv_ofmap | output logic [DATA_WIDTH-1:0][0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1] | Convolved output |
| conv_done  | output logic                        | Completion flag |

---

### `mac`
Core multiply-accumulate unit.

**Ports:**

| Port     | Type                                  | Description |
|---------|--------------------------------------|-------------|
| feature | input logic [DATA_WIDTH-1:0][0:KERNEL_SIZE-1][0:KERNEL_SIZE-1] | Input feature window |
| kernel  | input logic signed [DATA_WIDTH-1:0][0:KERNEL_SIZE-1][0:KERNEL_SIZE-1] | Kernel values |
| result  | output logic signed [MAC_RESULT_WIDTH-1:0] | Accumulated product result |

---

### `maxpool`
Performs 2×2 max pooling with stride 2.

**Ports:**

| Port   | Type                                | Description |
|-------|------------------------------------|-------------|
| clk    | input logic                         | System clock |
| reset  | input logic                         | Reset |
| en     | input logic                         | Enable signal |
| ifmap  | input logic [DATA_WIDTH-1:0][0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1] | Input feature map |
| ofmap  | output logic [DATA_WIDTH-1:0][0:(CONV_OFMAP_SIZE/2)-1][0:(CONV_OFMAP_SIZE/2)-1] | Pooled output |
| done_pool | output logic                     | Completion flag |

---

### `flatten`
Converts 2D pooled feature maps into a 1D vector.

**Ports:**

| Port        | Type                             | Description |
|------------|---------------------------------|-------------|
| flatten_in | input logic [DATA_WIDTH-1:0][0:POOL_OFMAP_SIZE-1][0:POOL_OFMAP_SIZE-1] | Input feature map |
| flatten_out | output logic [DATA_WIDTH-1:0][0:POOL_PIXEL_COUNT-1] | Flattened 1D vector |

---

### `gap` (Global Average Pooling)
Computes average per channel.

**Ports:**

| Port       | Type                                         | Description |
|-----------|---------------------------------------------|-------------|
| clk       | input logic                                  | System clock |
| rst       | input logic                                  | Reset |
| start     | input logic                                  | Start signal |
| input_fm  | input logic [CHANNELS-1:0][POOL_OFMAP_SIZE-1:0][POOL_OFMAP_SIZE-1:0] | Input feature maps |
| output_fm | output logic [DATA_WIDTH-1:0][CHANNELS-1:0] | Channel-wise average output |
| done      | output logic                                 | Completion flag |

---

### `argmax`
Determines the index of the maximum value for classification.

**Ports:**

| Port       | Type                                 | Description |
|-----------|-------------------------------------|-------------|
| data_in   | input logic [DATA_WIDTH-1:0][CHANNELS] | Input vector of channel outputs |
| max_index | output logic [INDEX_WIDTH-1:0]       | Index of the max value |
| max_value | output logic [DATA_WIDTH-1:0]        | Maximum value |

---

### `comparator`
Selects the maximum value among 4 inputs (used in pooling).

**Ports:**

| Port    | Type                        | Description |
|--------|-----------------------------|-------------|
| input1 | input logic [DATA_WIDTH-1:0] | Input 1 |
| input2 | input logic [DATA_WIDTH-1:0] | Input 2 |
| input3 | input logic [DATA_WIDTH-1:0] | Input 3 |
| input4 | input logic [DATA_WIDTH-1:0] | Input 4 |
| max_val | output logic [DATA_WIDTH-1:0] | Maximum of the 4 inputs |
