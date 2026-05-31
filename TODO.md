# TODO / Roadmap

Staged task list for the retroIC_sv library. Status keys: `[ ]` planned,
`[~]` in progress, `[x]` done. Update this file and `CHANGELOG.md` after each
meaningful change.

## Stage 0 — Repository skeleton (commit 1)

- [x] Create directory structure (`rtl/`, `sim/`, `formal/`, `docs/`,
      `scripts/`, `examples/`, `ci/`)
- [x] `README.md`, `LICENSE` (MIT), `CHANGELOG.md`, `TODO.md`, `CONTRIBUTING.md`
- [x] `docs/project_scope.md`
- [x] `docs/supported_chips.md` (all chips listed, status = planned)
- [x] `docs/coding_style.md`
- [x] `docs/verification_strategy.md`
- [x] `docs/memory_models.md`
- [x] `docs/bus_interface_notes.md`
- [x] `docs/tri_state_modeling.md`
- [x] `docs/pal_gal_replacement.md`
- [x] `docs/references.md`
- [x] Per-directory `README.md` files under `rtl/`, `sim/`, `scripts/`

## Stage 1 — Common package + helpers (commit 2)

- [x] `rtl/common/retro_ic_pkg.sv` — shared types/params/functions
- [x] `rtl/common/edge_detector.sv` — rising/falling edge pulse helper
- [x] `rtl/common/synchronizer.sv` — 2FF input synchronizer
- [ ] Helper testbenches (sim/common)

## Stage 2 — Memory wrappers (commit 2)

- [x] `rtl/memory/generic_async_rom.sv` (ADDR_WIDTH, DATA_WIDTH, INIT_FILE,
      REGISTER_OUTPUT)
- [x] `rtl/memory/generic_sram.sv` (ADDR_WIDTH, DATA_WIDTH, byte enable,
      sync write, async/sync read mode)
- [x] `rtl/memory/eprom_2716.sv`
- [x] `rtl/memory/eprom_2732.sv`
- [x] `rtl/memory/eprom_2764.sv`
- [x] `rtl/memory/sram_6116.sv`
- [x] `rtl/memory/sram_6264.sv`
- [x] Self-checking testbenches for each + run scripts
- [ ] Remaining EPROM wrappers: 2708, 27128, 27256, 27512
- [ ] Remaining SRAM wrappers: 2114, 62256

## Stage 3 — CMOS 4000/4500 (commit 3)

- [ ] `rtl/cmos4000/cd4013.sv` — dual D flip-flop
- [ ] `rtl/cmos4000/cd4040.sv` — 12-stage ripple counter (sync model)
- [ ] `rtl/cmos4000/cd4051.sv` — 8:1 analog-mux modeled digitally
- [ ] `rtl/cmos4000/cd4066.sv` — quad bilateral switch modeled digitally
- [ ] `rtl/cmos4000/cd4520.sv` — dual 4-bit binary counter
- [ ] Self-checking testbenches for each
- [ ] Remaining CMOS: CD4020, CD4052, CD4053, CD4069, CD4511, CD4538

## Stage 4 — Intel peripherals

- [ ] `rtl/intel82xx/i8255.sv` — PPI, mode 0 first; ports A/B/C; control word;
      port C bit set/reset. TODO: modes 1 and 2.
- [ ] `rtl/intel82xx/i8254.sv` — PIT, 3 counters; latch command; LSB/MSB/LSB-MSB
      access; modes 0, 2, 3 first. TODO: modes 1, 4, 5.
- [ ] `rtl/intel82xx/i8253.sv` — wrapper/variant of 8254 (no read-back command)
- [ ] Tests for control-word handling, port I/O, counter timing
- [ ] Later phase: 8251 USART, 8212 latch

## Stage 5 — Motorola peripherals

- [ ] `rtl/motorola68xx/m6821.sv` — PIA; ORA/ORB, DDRA/DDRB, CRA/CRB; CA/CB
      interrupt subset. TODO: full handshake modes.
- [ ] `rtl/motorola68xx/m6840.sv` — PTM; 3 timer channels; common modes; IRQ.
- [ ] Tests for register access, data direction, interrupt flags, timer counts
- [ ] Later phase: 6850 ACIA

## Stage 6 — Video

- [ ] `rtl/video/mc6845.sv` — CRTC register file + H/V timing, display enable,
      cursor hooks, MA / RA outputs, HSYNC / VSYNC.
- [ ] Test register writes + a known simple video mode's generated timing
- [ ] Later: document HD6845 / UM6845 / 6545 variant differences

## Stage 7 — PAL/GAL replacement

- [ ] `rtl/pal_gal/pal_comb_decode.sv` — combinational decode template
- [ ] `rtl/pal_gal/pal_registered.sv` — registered/stateful template
- [ ] `rtl/pal_gal/prom_lut.sv` — small PROM lookup (combinational + registered)
- [ ] Examples: Z80 decoder, 6809 decoder, arcade ROM-select, video timing PROM

## Stage 8 — Cross-cutting

- [ ] Formal stubs for counters, RAM wrappers, bus interfaces
- [ ] CI config under `ci/`
- [ ] Top-level `make test` aggregating all category scripts
