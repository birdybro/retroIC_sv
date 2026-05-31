# rtl/cmos4000

4000/4500-series CMOS logic, modeled as **digital equivalents** — never analog.
These parts show up as glue logic, dividers, mux/switch fabric, and display
decoders on vintage boards.

> No analog modeling. CD4051/4052/4053/4066 are digital mux/switch elements (no
> Ron, no analog bidirectional behavior, no voltage thresholds). CD4538 is a
> digital one-shot measured in clock ticks, not an RC time constant. See
> [docs/coding_style.md](../../docs/coding_style.md).

## Contents (planned)

| File | Part | Model |
|---|---|---|
| `cd4013.sv` | dual D flip-flop | two clocked D-FFs with set/reset |
| `cd4020.sv` | 14-stage ripple counter | sync counter + clock enable |
| `cd4040.sv` | 12-stage ripple counter | sync counter + clock enable |
| `cd4051.sv` | 8:1 mux/demux | digital 8:1 mux / 1:8 demux + inhibit |
| `cd4052.sv` | dual 4:1 mux/demux | digital dual 4:1 mux |
| `cd4053.sv` | triple 2:1 mux/demux | digital triple 2:1 mux |
| `cd4066.sv` | quad bilateral switch | digital quad pass/block switch |
| `cd4069.sv` | hex inverter | six combinational inverters |
| `cd4511.sv` | BCD→7-seg latch/decoder | latch + BCD→segment LUT |
| `cd4520.sv` | dual 4-bit counter | two sync up-counters + clock enable |
| `cd4538.sv` | dual monostable | digital one-shot, tick-based pulse width |

## Ripple counters

Offered in two forms where relevant: a simulation-only pin-faithful **ripple**
reference, and a synthesizable **synchronous** model using one clock and a clock
enable. The synchronous model updates all stage outputs on the same edge; the
header documents this divergence from true ripple behavior.
