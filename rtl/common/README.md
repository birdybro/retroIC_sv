# rtl/common

Shared infrastructure used by the chip models: a common package and a small set
of generic helper modules.

> These helpers exist to support the public chip models. This is **not** a
> 7400-series TTL library — only the minimum generic building blocks
> (synchronizers, edge detectors, small muxes/counters/latches) needed by the
> models in the other `rtl/` directories.

## Contents (planned)

- `retro_ic_pkg.sv` — shared package: common typedefs, helper functions, and
  any library-wide parameters/enums.
- `synchronizer.sv` — N-stage (default 2FF) input synchronizer for crossing an
  asynchronous board signal into the FPGA clock domain.
- `edge_detector.sv` — rising/falling edge detector producing a one-cycle pulse,
  used to turn external strobes (`RD#`, `WR#`, `E`) into internal commit pulses.

## Conventions

Follow [docs/coding_style.md](../../docs/coding_style.md): `logic`, `always_ff` /
`always_comb`, single clock, clock enables (no gated clocks), no internal
tri-state, active-low signals suffixed `_n`.
