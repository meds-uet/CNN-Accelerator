# Contributing to CNN Accelerator

We welcome contributions that improve the CNN Accelerator — RTL modules, testbenches, optimizations, or documentation.

## How to Contribute

1. **Fork** the repository.
2. **Create a branch** for your work:

   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Implement your changes** following the coding standards below.
4. **Commit** with a clear message:

   ```bash
   git commit -m "Add 2x2 comparator module for max pooling"
   ```
5. **Push & open a Pull Request**, including:

   * Summary of changes
   * Testbench results or simulation logs
   * Any performance or synthesis impact

## Coding Standards

* Use **SystemVerilog 2012** syntax.
* **4-space indentation**.
* Header comment for each file:

  ```verilog
  // Module: comparator
  // Description: 2x2 comparator for CNN max-pooling
  // Author: [Your Name]
  // Date: [DD/MM/YYYY]
  ```
* **Naming conventions**:

  * Parameters/constants: `UPPERCASE` (`DATA_WIDTH`)
  * Signals: `lowercase_with_underscores` (`max_top`)
  * Modules: `CamelCase` (`ConvCore`)
* Use `always_comb`, `always_ff`, `always_latch` appropriately.
* Prefer descriptive comments; avoid hardcoding widths.

## Testing & Simulation

* Provide a **testbench** under `test/` for each module.
* Supported tools: **QuestaSim / ModelSim**.
* Include simulation logs, `.vcd` waveforms, or a summary in `tests/Tests.md`.

## Synthesis Guidelines

* Run lint/synthesis (`yosys`, `vivado`, `quartus_sh`) for synthesizable modules.
* Avoid inferred latches or combinational loops.
* Document timing-critical paths or pipeline stages.

## Reporting Issues

Include:

* Simulation tool & version
* Error or warning messages
* Steps to reproduce
* Optional: waveform screenshots or code snippets

Use GitHub Issues with labels: `bug`, `enhancement`, `documentation`.

## Code of Conduct

Be professional and respectful. All contributions are welcome.
