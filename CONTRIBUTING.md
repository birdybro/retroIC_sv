# Contributing to retroIC_sv

Thanks for your interest. This project collects clean, reusable, synthesizable
SystemVerilog models of vintage digital support ICs. The bar for a contribution
is: **synthesizable, deterministic, test-covered, documented, and originally
written.**

## Ground rules

1. **Original HDL only.** Write models from publicly available behavioral
   descriptions and datasheets. **Do not copy HDL** from MAME, MiSTer,
   FPGAArcade, or any other project unless its license is compatible with MIT
   *and* you add clear attribution (see below). When in doubt, don't.
2. **No copyrighted content.** Do not commit copyrighted datasheet text or ROM
   images. Memory models load contents from user-supplied `$readmemh` files; the
   repo ships only tiny synthetic test vectors.
3. **Stay in scope.** Digital, synthesizable support ICs from the listed
   families. No analog parts (amps, op-amps, regulators, ULN arrays, NE555-style
   analog timers, RC behavior) and no literal 7400-series TTL library. See
   [docs/project_scope.md](docs/project_scope.md).

## Coding standards

Follow [docs/coding_style.md](docs/coding_style.md) in full. The essentials:

- Synth-safe SystemVerilog: `logic` (not `reg`/`wire`), `always_ff` for
  sequential, `always_comb` for combinational, explicit bit widths.
- One module per file; file name == module name.
- No inferred latches, no gated clocks — use clock enables.
- **No internal tri-state.** Expose `data_out` + `data_oe`. See
  [docs/tri_state_modeling.md](docs/tri_state_modeling.md).
- Active-low signals end in `_n` (`ce_n`, `oe_n`, `we_n`, `cs_n`, `reset_n`).
- No `#` delays or other unsynthesizable constructs in `rtl/` — delays live only
  in testbenches.
- Avoid `*` / `/` in datapaths unless justified and documented.

## Required module header

Every public module starts with a header comment covering:

- original chip / function
- intended FPGA modeling approach
- important differences from the physical IC
- parameters
- ports
- reset behavior
- synthesis notes
- verification status

A template lives in [docs/coding_style.md](docs/coding_style.md).

## Tests

- Add **at least one self-checking testbench per module** under the mirroring
  `sim/` subdirectory.
- Verilator is the primary simulation path. Tests must exit non-zero on failure.
- Cover the relevant subset of: reset, chip select, read/write, output enable,
  bus direction, truth tables, and representative timing.
- Python is allowed only for **test orchestration or expected-vector
  generation**, never to implement hardware behavior.

See [docs/verification_strategy.md](docs/verification_strategy.md).

## Attribution

If an external reference materially influenced a model (a published timing
diagram, a behavioral writeup, a register map), cite it in the module header and
in [docs/references.md](docs/references.md). If you adapt anything from a
license-compatible project, name the project, its license, and the file.

## Pull request checklist

- [ ] Module is synthesizable and passes a Verilator lint.
- [ ] One module per file; header comment complete.
- [ ] Self-checking testbench added and passing.
- [ ] `docs/supported_chips.md` status updated.
- [ ] `CHANGELOG.md` and `TODO.md` updated.
- [ ] No copyrighted content; attribution added where applicable.
