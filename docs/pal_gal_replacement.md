# PAL / GAL / PROM Replacement

Vintage boards are full of programmable logic: PAL/GAL devices doing address
decode, chip-select generation, video timing decode, and copy-protection; and
small bipolar PROMs (82S123, 82S129, …) used as lookup tables for color, video
timing, or sequencing.

retroIC_sv does **not** try to emulate PAL/GAL silicon (the AND/OR array, fuse
map, or sense amps). Instead it reproduces the **board-level logic equations**
in clean SystemVerilog. The goal is functional equivalence at the pins, not a
model of the device internals.

## Why equations, not silicon

A 16L8 or GAL16V8 implements a sum-of-products from its inputs to its outputs.
If you know the equations (from the board's published JEDEC fuse map, a logic
listing, or by reverse-engineering the truth table), you can write them directly
as `always_comb` logic that synthesizes to exactly the gates you need — smaller,
faster, and readable. Modeling the fuse array would be slower and pointless.

## Templates

Three reusable templates live in [`rtl/pal_gal/`](../rtl/pal_gal/):

### 1. Combinational decode — `pal_comb_decode`

For pure combinational PALs (16L8, 16P8, GAL combinational mode). You express the
output equations in an `always_comb` block. The template is a documented skeleton
showing the structure (inputs grouped, default-assigned outputs, one comment per
product term) so each board decode is a small, self-contained module.

Use it for: address-range decode, chip-select generation, simple protection
combinational checks.

### 2. Registered / stateful — `pal_registered`

For registered PALs (16R4/16R6/16R8, GAL registered mode) — outputs are flip-
flops clocked by the PAL's clock pin, with combinational next-state logic. The
template provides the clocked output registers plus an `always_comb` next-state
block and an output-enable input (`oe_n`) matching the real device's `OE` pin
(modeled as `data_oe`, never internal tri-state).

Use it for: state machines baked into protection PALs, sequencers, registered
chip-select with history.

### 3. Small PROM lookup — `prom_lut`

For bipolar PROMs used as lookup tables. It is just a small ROM: address in,
data out, contents from `$readmemh`. Available combinational (async read) or
registered (sync read) like `generic_async_rom`.

Use it for: color PROMs, video timing PROMs, sequencer PROMs, priority PROMs.

## How to translate a PAL equation

Given board documentation like:

```
/CS_RAM = /A15 * /A14            ; RAM at 0000-3FFF
/CS_IO  =  A15 *  A14 * /A13     ; I/O at C000-DFFF
```

(`/` = active low, `*` = AND, `+` = OR), translate directly:

```systemverilog
always_comb begin
    // /CS_RAM active (low) for A15=0, A14=0
    cs_ram_n = !(~addr[15] & ~addr[14]);
    // /CS_IO active (low) for A15=1, A14=1, A13=0
    cs_io_n  = !( addr[15] &  addr[14] & ~addr[13]);
end
```

Notes:

- A leading `/` on the output name means the **output is active low** — the
  product term defines when it is *active*, so the registered/buffered output is
  the inverse, hence the `!(...)`.
- `+` (OR) between product terms becomes `|` between the term expressions.
- Keep one comment per product term tying it back to the original equation; this
  is what makes the HDL auditable against the board.

## Worked examples

In [`examples/`](../examples/):

- **`z80_board_glue/`** — a Z80 memory-map decoder (ROM / RAM / I/O select).
- **`6809_board_glue/`** — a 6809 memory-map decoder.
- **`arcade_address_decode/`** — sprite/tile ROM bank select for an arcade
  graphics board.
- **`crtc_video_timing/`** — a video-timing PROM lookup feeding sync/blank.

Each example is a small module plus a self-checking testbench demonstrating the
equation-to-HDL translation and how to verify it against the intended truth
table.

## Protection PALs

Copy-protection PALs are handled the same way: recover the truth table (every
input combination → output), then express it as `pal_comb_decode` /
`pal_registered`, or load it into `prom_lut` directly as a lookup. The model
reproduces the response the board expects; it does not need to mimic the device's
timing or internal structure.
