# Installation & Setup

## Requirements

- **Simulators:** ModelSim, QuestaSim, Vivado, or Verilator  
- **Synthesis Tools:** Vivado, Quartus, or Synopsys DC  
- **Python:** for image pre/post-processing  
  - `numpy`
  - `Pillow`

## Step-by-Step Setup

```bash
git clone https://github.com/meds-uet/CNN-Accelerator.git
cd CNN-Accelerator
make setup
```

### Run Simulation (Modelsim)
```bash
make sim
```

### Run Synthesis (Vivado)
```bash
make synth
```
