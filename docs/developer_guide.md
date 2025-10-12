# Developer Guide

## Simulation Flow

Run with Verilator:

```bash
make sim
```

## Testbench Structure

- **cnn_tb.sv** — top testbench  
- **img_loader.sv** — image input  
- **output_checker.sv** — verifies outputs  

## Adding a New Test

Add a new image and script:

```
test/imgs/
├── new_input.png
├── expected_output.txt
```

Then update the testbench path.
