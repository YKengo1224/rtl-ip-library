## Project Overview
- A collection of repositories containing tools for FPGA development and SystemVerilog IPs.

## Coding Style
- **RTL**:
  - Use the `logic` type for combinational logic signals and the `reg` type for flip-flops (FF).
  - Prefix input signals with `i_` and output signals with `o_` (excluding clock and reset signals).
  - Suffix all signal names with their corresponding clock domain name, excluding clock and reset signals (e.g., `data_aclk`).
  - For `reg` type signals, append `r` to the clock domain suffix (e.g., `data_aclkr`).
- **UVM**:
  - Use UVM for all RTL simulation code.

## Git
- Follow the GitHub Flow workflow.
- Prefix commit messages with one of the following tags: `{add, refactor, update, bugfix}`.

## Constraints & Prohibitions
- Never modify files inside the `legacy/` or `deprecated/` directories.
- Do not add external dependencies without prior permission.
