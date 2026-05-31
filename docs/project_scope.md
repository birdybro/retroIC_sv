# Project Scope

## Purpose

retroIC_sv is a library of **synthesizable SystemVerilog models of common
1970s/1980s digital support ICs** used in arcade boards, home computers,
terminals, game systems, and embedded controller boards. It exists so that an
FPGA core author can instantiate a faithful-enough model of a ROM, RAM, CMOS
logic part, or peripheral controller without re-deriving it from a datasheet.

The guiding principle is **board-level functional equivalence**: reproduce the
behavior a chip presents to the rest of the board, implemented in clean,
FPGA-friendly HDL. This is explicitly **not** a transistor-level or die-level
preservation effort.

## In scope

1. **Parallel ROM / EPROM** — 2708, 2716, 2732, 2764, 27128, 27256, 27512, and a
   generic parameterized async ROM wrapper.
2. **Static RAM** — 2114 (1K×4), 6116 (2K×8), 6264 (8K×8), 62256 (32K×8), and a
   generic parameterized SRAM wrapper.
3. **4000/4500-series CMOS logic** useful in FPGA cores — CD4013, CD4020, CD4040,
   CD4051, CD4052, CD4053, CD4066, CD4069, CD4511, CD4520, CD4538. Modeled as
   **digital equivalents**, never analog.
4. **Intel-style peripherals** — 8253/8254 PIT, 8255 PPI; later 8251 USART and
   8212 latch.
5. **Motorola-style peripherals** — 6821 PIA, 6840 PTM, 6845 CRTC; later 6850
   ACIA.
6. **PAL/GAL/PROM replacement helpers** — combinational and registered
   templates, a small PROM lookup module, and worked board-decode examples.

Supporting infrastructure: self-checking testbenches (Verilator-first), per
category run scripts, light formal stubs, and the documentation set in this
directory.

## Out of scope

- **Analog devices of any kind**: audio power amplifiers, op-amps, voltage
  regulators, ULN2003-style driver arrays, NE555-style analog timers, and any
  model that depends on RC charge curves, switch resistance, voltage thresholds,
  or other continuous-time physics. Where a real part has an analog aspect
  (CD4538 monostable timing, CD4051/4066 switch behavior), we model the
  **digital intent** with a deterministic clocked equivalent and document the
  difference.
- **A literal 7400-series TTL library.** The repo may contain small *internal*
  helper modules (muxes, counters, latches, edge detectors, synchronizers) where
  a public model needs them, but enumerating 74xx gates is not a goal.
- **Copyrighted material.** No ROM images, no copied datasheet text, no HDL
  lifted from other projects without a compatible license and attribution.

## Modeling philosophy

- **Deterministic and FPGA-friendly.** Real chips can power up undefined, go
  metastable, or behave analog. We choose deterministic behavior, put any
  power-up state behind a parameter where useful, and document every divergence.
- **Cycle behavior where it matters.** Vintage buses are asynchronous; FPGA
  cores are synchronous. Models present externally faithful behavior while being
  clean to clock internally. Where exact cycle timing matters (counters, CRTC,
  PIT), we state the assumptions and test them.
- **Small and composable.** Each model is easy to read and easy to instantiate
  in a larger arcade/computer core.

## Relationship to MiSTer / Cyclone V

The conventions here follow the bundled
[`hdl-coding-guidelines/`](../hdl-coding-guidelines/00-INDEX.md) reference, which
targets Intel Cyclone V (the DE10-Nano / MiSTer FPGA). The models are not tied
to that part — they target a generic synthesizable subset — but memory and reset
choices are made with Cyclone V resource inference (M10K / MLAB / flops) in mind.
