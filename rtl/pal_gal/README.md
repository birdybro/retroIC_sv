# rtl/pal_gal

PAL/GAL/PROM **replacement** templates. The purpose is to reproduce a board's
logic equations in clean HDL, **not** to emulate PAL/GAL silicon (no fuse array,
no sense amps). See
[docs/pal_gal_replacement.md](../../docs/pal_gal_replacement.md) for the full
rationale and a worked equation-to-HDL translation.

## Contents (planned)

| File | Replaces | Model |
|---|---|---|
| `pal_comb_decode.sv` | combinational PAL (16L8/GAL comb mode) | documented `always_comb` sum-of-products template |
| `pal_registered.sv` | registered PAL (16R4/R6/R8, GAL reg mode) | clocked output registers + comb next-state + `oe`/`data_oe` |
| `prom_lut.sv` | small bipolar PROM (82S123/82S129) | LUT via `$readmemh`, combinational or registered read |

## Examples

Worked board-decode examples live in [`examples/`](../../examples/):
Z80 decoder, 6809 decoder, arcade ROM-select, video-timing PROM. Each comes with
a self-checking testbench demonstrating verification against the intended truth
table.
