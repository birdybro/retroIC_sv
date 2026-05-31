# Changelog

All notable changes to this project are documented here. The format is loosely
based on [Keep a Changelog](https://keepachangelog.com/). This project is
pre-1.0; the public module interfaces may still change.

## [Unreleased]

### Added
- **CMOS 4000-series models**: `cd4013` (dual D flip-flop), `cd4040` (12-stage
  counter), `cd4520` (dual 4-bit counter) using FPGA-safe synchronous logic
  with the chip clock edge-detected against the system clock; `cd4051` (8:1
  mux / 1:8 demux) and `cd4066` (quad bilateral switch) as combinational
  digital models of the analog switches (no analog behavior). Self-checking
  testbenches for all five pass under Verilator 5.x.
- **Common package + helpers**: `rtl/common/retro_ic_pkg.sv` (library
  constants + sizing helper), `synchronizer.sv` (N-stage CDC), and
  `edge_detector.sv` (rising/falling pulse).
- **Memory base modules**: `generic_async_rom.sv` (params `ADDR_WIDTH`,
  `DATA_WIDTH`, `INIT_FILE`, `REGISTER_OUTPUT`) and `generic_sram.sv` (params
  `ADDR_WIDTH`, `DATA_WIDTH`, `BYTE_ENABLE`, `SYNC_READ`, `INIT_FILE`;
  synchronous write, async/sync read, `din`/`dout`/`dout_oe`).
- **Memory wrappers**: `eprom_2716`, `eprom_2732`, `eprom_2764`, `sram_6116`,
  `sram_6264` (6264 with dual CS1#/CS2 selects).
- **Self-checking testbenches** for all of the above under `sim/memory/` plus a
  tiny synthetic init vector `test_rom16.hex`. All 7 pass under Verilator 5.x.
- **Test infrastructure**: `scripts/run_category.sh`, `scripts/run_tests.sh`,
  and `scripts/Makefile` (Verilator `--binary --timing`).
- Repository structure: `rtl/`, `sim/`, `formal/`, `docs/`, `scripts/`,
  `examples/`, `ci/` with category subdirectories.
- Top-level docs: `README.md`, `CHANGELOG.md`, `TODO.md`, `CONTRIBUTING.md`.
- `LICENSE` (MIT).
- Documentation set under `docs/`: project scope, supported-chips table,
  coding style, verification strategy, memory models, bus interface notes,
  tri-state modeling, PAL/GAL replacement, references.
- Per-directory `README.md` files describing the intent of each `rtl/`
  category, plus `sim/` and `scripts/` overviews.

[Unreleased]: https://github.com/
