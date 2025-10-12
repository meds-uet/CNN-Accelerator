# User Guide

## Overview

This section describes how to integrate and use the CNN accelerator in your FPGA or SoC design.

### Instantiation Example

```systemverilog
cnn_accelerator #(
  .DATA_WIDTH(8),
  .IFMAP_SIZE(256)
) u_cnn_accelerator (
  .clk(clk),
  .reset(reset),
  .en(start),
  .done(done)
);
```

### Run Flow

1. Load input image.
2. Assert `en`.
3. Wait for `done` signal.
4. Read `cnn_ofmap` output.

---

## Simulation

To run simulations:

```bash
make sim
```

Supported simulators:
- Verilator
- VCS
- QuestaSim
