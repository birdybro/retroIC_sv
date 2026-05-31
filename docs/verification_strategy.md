# Verification Strategy

## Goals

Every public module ships with at least one **self-checking testbench**. Tests
are deterministic, fast, and exit **non-zero on failure** so they work in CI and
in `make test`.

## Tooling

- **Verilator** is the primary open-source simulation path. Testbenches are
  written to elaborate cleanly under Verilator and (where practical) under other
  simulators (Icarus Verilog, commercial tools).
- **Python** is permitted only for **test orchestration** (running suites,
  collecting results) and **expected-vector generation** (precomputing golden
  outputs). Python never implements hardware behavior — that lives in HDL.
- Per-category run scripts / Makefiles live under [`scripts/`](../scripts/). A
  top-level aggregator runs all categories.

## Testbench conventions

- A testbench is named `tb_<module>.sv` and lives under the mirroring `sim/`
  subdirectory (e.g. `sim/memory/tb_generic_sram.sv`).
- Drive a single clock; model the DUT's asynchronous vintage interface by
  sequencing inputs around clock edges. **Delays (`#`) are allowed only in
  testbenches**, never in `rtl/`.
- Maintain an `error_count`. Each check increments it on mismatch and prints a
  clear `FAIL:` line with expected vs actual. At the end:
  - print `PASS` and `$finish` with status 0 if `error_count == 0`,
  - print `FAIL (<n> errors)` and `$fatal`/non-zero exit otherwise.
- Prefer a small `check(actual, expected, label)` task to keep tests terse.

## What to test per category

### Memory wrappers (ROM / SRAM)

- Address width and data width (corners: address 0, max address, walking bits).
- Chip enable (`ce_n`) gating: no output / no write when deselected.
- Output enable (`oe_n`): `data_oe` deasserted and `data_out` not driving when
  `oe_n` high.
- Write enable (`we_n`) for RAM: write only on the intended condition.
- Bus direction: `dout_oe` correct across read/write/idle.
- Initialization: `$readmemh` contents read back correctly (ROM, and RAM if
  init supported).
- Async-read vs sync-read mode behaves per parameter (combinational vs 1-cycle
  latency).

### Counters / timers (CD40xx, 8253/8254, 6840)

- Reset value and reset behavior.
- Clock-enable gating (counts only when enabled).
- Count sequence, **terminal count**, wrap, and reload.
- Output waveform shape (e.g. square wave for PIT mode 3, single pulse for
  mode 0).
- Load formats where applicable (LSB / MSB / LSB-then-MSB for the PIT).

### Logic / mux / switch (CD4013, CD4051, CD4066, CD4511, CD4069)

- Basic functional **truth tables**.
- Select/inhibit/enable behavior.
- Latch vs transparent behavior where relevant.

### Bus peripherals (8255, 6821)

- Reset state of registers.
- Control-word / mode-register writes take effect.
- Read/write of each register through the CPU bus interface.
- Data-direction behavior (which pins drive vs sample).
- Interrupt / status flag set and clear (where modeled).

### CRTC (6845)

- Register-file writes via the address/data interface.
- Generated timing for a **known simple video mode**: horizontal/vertical
  totals, display-enable window, HSYNC/VSYNC position and width, MA/RA
  progression.

## Formal verification

Light formal **stubs** are added where they pay off, especially for:

- counters (no overflow past modulus, reload correctness),
- RAM wrappers (write-then-read returns the written value; deselect preserves),
- bus interfaces (no `data_oe` when deselected; one-hot register select).

Stubs live under [`formal/`](../formal/) mirroring the `rtl/` categories. They
are intentionally minimal (a few `assert`/`assume` properties) and are not
required to pass under every tool — they document intended invariants and can be
driven by SymbiYosys where available.

## Minimum bar for a new module

1. Elaborates and lints clean under Verilator.
2. At least one self-checking `tb_<module>.sv` covering the category checklist
   above (the relevant subset).
3. `docs/supported_chips.md` status updated; `CHANGELOG.md` / `TODO.md` updated.
