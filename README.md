# retroIC_sv

Reusable, synthesizable **SystemVerilog models of common 1970s/1980s digital
support ICs** — the ROMs, RAMs, CMOS logic, peripheral controllers, and PAL/GAL
glue that surround the CPU on vintage arcade boards, home computers, terminals,
and game systems.

The goal is a clean library you can drop into an FPGA recreation (MiSTer-style
cores, DE10-Nano projects, or any other vintage-hardware reimplementation) when
you need a faithful-enough model of a support chip without re-deriving it from a
datasheet every time.

## Project purpose

- Provide **synthesizable, timing-conscious, FPGA-friendly** HDL models of the
  digital support ICs that appear over and over in vintage digital hardware.
- Favor **board-level functional equivalence** over transistor-level silicon
  preservation. This is a reusable HDL library, not a die-shot reverse
  engineering project.
- Keep every model **small, readable, deterministic, and easy to instantiate**
  inside a larger core.
- Document, per chip, exactly where the model differs from the physical part so
  integrators are never surprised.

## Supported chip families

| Category | Examples |
|---|---|
| Parallel ROM / EPROM | 2708, 2716, 2732, 2764, 27128, 27256, 27512, generic async ROM |
| Static RAM | 2114, 6116, 6264, 62256, generic SRAM |
| 4000/4500 CMOS logic | CD4013, CD4020, CD4040, CD4051, CD4052, CD4053, CD4066, CD4069, CD4511, CD4520, CD4538 |
| Intel-style peripherals | 8255 PPI, 8253/8254 PIT, (later: 8251 USART, 8212 latch) |
| Motorola-style peripherals | 6821 PIA, 6840 PTM, 6845 CRTC, (later: 6850 ACIA) |
| PAL/GAL/PROM replacement | combinational + registered templates, small PROM LUT, decode examples |

See [docs/supported_chips.md](docs/supported_chips.md) for the full table with
per-chip status, original function, modeling approach, and caveats.

## In scope

- Digital, synthesizable models of the chip families above.
- Self-checking testbenches (Verilator-first) and per-category run scripts.
- Light formal stubs for counters, memories, and bus interfaces.
- Documentation on how to integrate ROM loading, replace board PALs, and wire
  Intel-style vs Motorola-style buses.

## Out of scope

- **Analog parts.** No audio amplifiers, op-amps, voltage regulators, ULN driver
  arrays, NE555-style analog timers, or discrete RC behavior. Where a real part
  is analog (e.g. CD4538 monostable, CD4051 switch resistance) we model the
  **digital intent**, not the analog physics, and say so.
- **A literal 7400-series TTL library.** Small internal helpers (muxes,
  counters, latches, edge detectors, synchronizers) exist where needed, but the
  *public* models target the families listed above.
- **Copyrighted ROM contents or datasheet text.** Models are written from
  publicly available behavioral descriptions. Bring your own ROM images.

## Synthesis goals

- Synth-safe SystemVerilog subset: `logic`, `always_ff`, `always_comb`, explicit
  widths, no inferred latches, no gated clocks, clock enables instead.
- **No internal tri-state.** Chips with tri-state pins expose `data_out` +
  `data_oe`; an optional simulation-only wrapper resolves a shared bus. See
  [docs/tri_state_modeling.md](docs/tri_state_modeling.md).
- Targets generic FPGAs; conventions follow the bundled Cyclone V / Quartus
  guidance in [`hdl-coding-guidelines/`](hdl-coding-guidelines/00-INDEX.md).

## Simulation goals

- [Verilator](https://www.veripool.org/verilator/) is the primary open-source
  simulation path; testbenches are self-checking and exit non-zero on failure.
- Per-category Makefiles/scripts under [`scripts/`](scripts/) run the tests.
- Tests cover reset, chip select, read/write, output enable, bus direction,
  truth tables, and representative timing sequences.

## Example use cases

- Replacing the work RAM, character ROM, and tile ROM models in a MiSTer-style
  arcade core with parameterized, test-covered wrappers.
- Standing in for an 8255 PPI or 6821 PIA on a recreated controller board.
- Driving video timing from a 6845 CRTC core.
- Replacing board address-decode / chip-select / protection PALs with clean,
  readable HDL equations (see [`examples/`](examples/)).

## Repository layout

```
docs/                 project + per-topic documentation
rtl/                  synthesizable models, one module per file
  common/             shared package + small helper modules
  memory/             ROM / EPROM / SRAM wrappers
  cmos4000/           4000/4500-series CMOS logic
  intel82xx/          8253/8254/8255/8251/8212
  motorola68xx/       6821/6840/6850
  video/              6845 CRTC
  pal_gal/            PAL/GAL/PROM replacement templates
sim/                  self-checking testbenches, mirrors rtl/ layout
formal/               formal verification stubs
scripts/              test-run scripts and helpers
examples/             board-glue integration examples
ci/                   continuous-integration config
hdl-coding-guidelines/  bundled Cyclone V HDL practice reference
```

## Status

Early bring-up. The memory wrappers and a first set of CMOS parts are the
initial focus; peripheral controllers (8255, 8253/8254, 6821, 6845) follow.
Track progress in [TODO.md](TODO.md) and [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE). Original HDL written from public behavioral descriptions. No
code is copied from MAME, MiSTer, FPGAArcade, or other projects, and no
copyrighted datasheet text or ROM content is included. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the attribution policy.
