# User Guide

## Overview

This section describes how to **integrate, configure, and use** the CNN Hardware Accelerator in FPGA or SoC designs.  
It assumes you already have the RTL source files available and basic familiarity with SystemVerilog simulation and synthesis using **Vivado** or **ModelSim/QuestaSim**.

---

## Integration in RTL Design

### Configuration Options & Register Map

All configuration parameters are defined in `cnn_defs.svh`.

| Parameter | Default | Description |
|------------|----------|-------------|
| DATA_WIDTH | 8 | Bit width |
| IFMAP_SIZE | 256 | Image dimension |
| KERNEL_SIZE | 3 | Convolution kernel size |
| STRIDE | 1 | Convolution stride |
| PADDING | 1 | Zero-padding size |


### Instantiation Example

To include the CNN accelerator in your top-level design, instantiate it as shown below:

```systemverilog
cnn_accelerator #(
  .DATA_WIDTH(8),
  .IFMAP_SIZE(256),
  .KERNEL_SIZE(3),
  .STRIDE(1),
  .PADDING(1)
) u_cnn_accelerator (
  .clk          (clk),
  .reset        (reset),
  .en           (start),
  .done         (done),
  .cnn_ifmap    (input_image),
  .weights      (kernel_data),
  .cnn_ofmap    (output_result)
);
```

### Signal Overview

| Signal | Direction | Description |
|--------|------------|-------------|
| `clk` | Input | System clock |
| `reset` | Input | Active-high asynchronous reset |
| `en` | Input | Start signal for CNN operation |
| `done` | Output | Indicates completion of processing |
| `cnn_ifmap` | Input | Input image pixel stream |
| `weights` | Input | Convolution filter/kernel weights |
| `cnn_ofmap` | Output | Final output feature map |

---

## Typical Run Flow

The CNN accelerator processes data in a pipelined fashion.  
A minimal operational sequence looks like this:

1. **Load input image and weights** into registers or memory.  
2. **Assert `en`** for one clock cycle to begin processing.  
3. **Wait for `done`** signal to indicate completion.  
4. **Read output** from `cnn_ofmap`.  
5. **Reset the module** (optional) before the next inference.

**Example Testbench Flow:**

```systemverilog
initial begin
  reset = 1;
  #10 reset = 0;
  en = 1;
  @(posedge done);
  $display("CNN Processing Completed!");
  $finish;
end
```

---

## Simulation Guide

This section explains how to run functional simulations of the CNN accelerator using **ModelSim** or **QuestaSim**.

### Running the Simulation

From the project root directory:

```bash
make sim
```

This will:
1. Compile all RTL and testbench files.  
2. Launch the simulator with the CNN testbench (`cnn_tb.sv`).  
3. Run the simulation and generate waveforms and logs.

Simulation outputs are stored under:

```
test/output/
```

---

### Supported Simulators

| Simulator | Description |
|------------|-------------|
| **ModelSim** | Industry-standard HDL simulator for debugging and analysis |
| **QuestaSim** | Enhanced commercial version with advanced verification features |

To manually invoke the simulator:

```bash
vsim -do run.do cnn_tb
```

or using the GUI:

```bash
vsim work.cnn_tb
add wave *
run -all
```

---

### Example Simulation Output

Expected console output (testbench messages):

```
[INFO] CNN Accelerator Simulation Started
[INFO] Convolution + ReLU completed
[INFO] Max Pooling completed
[PASS] Simulation completed successfully
```

Waveform file: `waves.vcd`  
Output images (if enabled): `ofmap.png`

---

## FPGA Implementation

### Synthesis Instructions (Vivado)

1. Open **Xilinx Vivado**.  
2. Create a new project and add all RTL files from `/rtl/`.  
3. Set the top module to `cnn_accelerator`.  
4. Configure global parameters as needed (`cnn_defs.svh`).  
5. Run **Synthesis → Implementation → Bitstream Generation**.

Recommended synthesis constraints:
- **Clock period:** 10 ns (100 MHz)  
- **Reset:** Active-high asynchronous  

---

### Example Resource Utilization (Xilinx Artix-7)

| Resource | Usage | Percentage |
|-----------|--------|------------|
| LUTs | 9,823 | 28% |
| FFs | 4,211 | 11% |
| DSPs | 54 | 72% |
| BRAM | 12 | 20% |

*(Actual utilization varies with IFMAP size and kernel configuration)*

---

## Summary

The CNN Accelerator provides a fully synthesizable, parameterized hardware design for real-time image inference.  
This guide covered:

- RTL instantiation and port mapping  
- Simulation with ModelSim/QuestaSim  
- Synthesis and FPGA implementation flow  
- Image conversion scripts for testbench I/O

Use this as your main operational reference for running and verifying the accelerator.
