# References

These are pointers to **publicly available** reference material to consult
manually when implementing or reviewing a model. The repository does **not**
redistribute copyrighted datasheets or ROM contents. Where a model is influenced
by a specific reference, cite it in the module header and add it here.

> **Policy:** Do not download copyrighted datasheets into the repository unless
> the license clearly permits redistribution. Link to manufacturer/archive
> sources instead. Write original HDL from behavioral descriptions; never copy
> HDL from other projects without a compatible license and attribution.

## How to use this list

- Look up the **register map**, **pinout**, **timing diagrams**, and **mode
  tables** from the original manufacturer datasheet (or a reputable archive).
- Cross-check behavior against more than one source where possible.
- Record any source that *materially* shaped a model in that module's header
  comment and add a bullet under "Per-chip" below.

## Internal references (in this repo)

- [`hdl-coding-guidelines/`](../hdl-coding-guidelines/00-INDEX.md) — bundled
  Cyclone V / Quartus HDL practice guide (synth subset, clocking/reset, memory
  inference, FSMs, verification). The house style here is consistent with it.
- [coding_style.md](coding_style.md), [memory_models.md](memory_models.md),
  [bus_interface_notes.md](bus_interface_notes.md),
  [tri_state_modeling.md](tri_state_modeling.md),
  [pal_gal_replacement.md](pal_gal_replacement.md).

## General / external

- **Verilator** — <https://www.veripool.org/verilator/> (primary sim path).
- **Bitsavers** component datasheet archive — historical datasheets for the
  parts modeled here (consult, do not redistribute).
- Manufacturer datasheets (Intel, Motorola/Freescale, Texas Instruments,
  Hitachi, NXP/Philips for CD4000-series) — primary source for register maps,
  pinouts, and timing.

## Per-chip (consult the original datasheet for each)

| Chip | What to consult |
|---|---|
| 2708/2716/2732/2764/27128/27256/27512 | pinout, address width, CE/OE/Vpp pin behavior, access time |
| 2114 / 6116 / 6264 / 62256 | pinout, CS/OE/WE behavior, common-I/O timing, multiple chip selects (6264) |
| CD4013 | D-FF truth table, async set/reset levels |
| CD4020 / CD4040 / CD4520 | stage count, reset behavior, clock edge / enable options |
| CD4051 / CD4052 / CD4053 | channel select map, inhibit pin behavior |
| CD4066 | switch control polarity, on/off behavior |
| CD4069 | inverter (trivial) |
| CD4511 | BCD→segment truth table, LT/BL/LE pin behavior |
| CD4538 | trigger edges, retrigger behavior, reset (timing is RC on real part — we use ticks) |
| 8255 | control word format, mode 0/1/2, port C bit set/reset, RD/WR/CS/A1:A0 |
| 8253 / 8254 | counter modes 0–5, read/write LSB/MSB formats, latch + (8254) read-back |
| 8251 / 8212 | mode/command words; latch/strobe behavior (later phase) |
| 6821 | register map (ORA/DDRA/CRA, ORB/DDRB/CRB), CA1/CA2/CB1/CB2 control bits |
| 6840 | timer control registers, modes, IRQ behavior, prescaler |
| 6845 | full register list R0–R17, H/V timing, cursor, interlace; variant notes (HD6845, UM6845, 6545) |
| 6850 | control/status registers, Tx/Rx (later phase) |
| PAL/GAL (16L8/16R8/GAL16V8) | sum-of-products structure, registered vs combinational outputs, OE |
| 82S123 / 82S129 PROM | size, bipolar PROM as LUT |

## Attribution

If any external reference (a published timing diagram, behavioral writeup, or a
license-compatible project) influences a model, add a line here naming the
source and, for adapted code, its license. As of the initial commits, all HDL is
original and written from public behavioral descriptions.
