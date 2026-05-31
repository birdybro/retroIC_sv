# sim

Self-checking testbenches, mirroring the `rtl/` directory layout
(`sim/memory/`, `sim/cmos4000/`, `sim/intel82xx/`, `sim/motorola68xx/`,
`sim/video/`, `sim/pal_gal/`, `sim/common/`).

See [docs/verification_strategy.md](../docs/verification_strategy.md) for the
full strategy.

## Conventions

- One testbench per module, named `tb_<module>.sv`, in the mirroring
  subdirectory.
- **Self-checking:** maintain an `error_count`, print clear `FAIL:` lines on
  mismatch, print `PASS` and exit 0 on success, exit non-zero on failure.
- **Verilator-first.** Testbenches elaborate cleanly under Verilator; delays
  (`#`) are permitted here (and only here), used to sequence the DUT's
  asynchronous vintage interface around a single clock.
- Tiny synthetic `*.hex` vectors used by memory tests live alongside the
  testbenches. **No copyrighted ROM contents.**

## Running

Use the per-category scripts/Makefiles in [`scripts/`](../scripts/), or the
top-level aggregator. Each category target builds and runs every `tb_*` in that
category and reports pass/fail.
