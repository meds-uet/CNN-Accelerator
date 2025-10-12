# API Reference

## Module: cnn_accelerator

**Ports:**

| Signal | Dir | Width | Description |
|---------|-----|--------|-------------|
| clk | in | 1 | Clock |
| reset | in | 1 | Reset |
| en | in | 1 | Enable |
| done | out | 1 | Completion flag |

## Module: conv.sv
- Performs convolution and ReLU
- FSM-controlled pipelined MAC array

## Module: maxpool.sv
- 2×2 pooling logic with stride 2
- Three-stage comparator
