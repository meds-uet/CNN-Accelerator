# Developer Guide

**CNN Hardware Accelerator – SystemVerilog Implementation**
**Developed by:** Abdullah Nadeem & Talha Ayyaz

---

## Simulation Flow

Run simulations with **ModelSim** or **QuestaSim**:

```bash
make sim
```

This command compiles RTL and testbench files, runs the testbench, and generates waveforms and output files in `test/`.

### Example Testbench Log

```
[INFO] CNN Accelerator Simulation Started
[INFO] Convolution + ReLU completed
[INFO] Max Pooling completed
[PASS] Simulation completed successfully
```

### Testbench Structure

```
test/
├── cnn_tb.sv          # Top testbench
├── img_loader.sv      # Loads input images into DUT
├── output_checker.sv  # Verifies outputs
├── imgs/              # Input images and reference outputs
```

* **cnn_tb.sv** – orchestrates DUT and simulation flow
* **img_loader.sv** – reads `.txt` inputs and feeds pixels to DUT
* **output_checker.sv** – compares DUT output with expected results

### Adding a New Test

1. Place input image and expected output in `test/imgs/`:

```
new_input.png
expected_output.txt
```

2. Convert the image to text format:

```bash
scripts/pgmToTxt.sh test/imgs/new_input.png test/imgs/new_input.txt 256
```

3. Update `cnn_tb.sv` to point to the new files.
4. Run simulation and visualize outputs:

```bash
python3 scripts/txtToPng.py test/output/output.txt test/output/output.png
```

### Best Practices

* Keep input/output files organized in `test/imgs/`
* Parameterize testbench for multiple IFMAP sizes
* Use waveforms to debug intermediate results

### Automation Scripts

* **pgmToTxt.sh** – converts PNG images to text for testbench input
* **txtToPng.py** – converts text output to PNG for visualization

---

End of Developer Guide
