# Coding Style

This is the house style for synthesizable SystemVerilog in retroIC_sv. It is
intentionally strict so that every model is FPGA-friendly, deterministic, and
readable. It is consistent with the bundled Cyclone V guidance in
[`hdl-coding-guidelines/`](../hdl-coding-guidelines/00-INDEX.md); when this doc
and the bundle disagree, the bundle's `[C]` (contract) rules win.

## Language subset

- **Synthesizable SystemVerilog only** in `rtl/`. No software-style constructs
  (dynamic arrays, `class`, queues, `fork/join`, recursion, etc.).
- Use **`logic`**, not `reg` or `wire`, except where tool compatibility forces
  otherwise (rare; comment it).
- **One module per file. File name == module name.** `foo_bar.sv` contains
  module `foo_bar`.
- Explicit bit widths everywhere. No bare decimal literals on buses; size them
  (`8'h00`, `1'b0`, `'0` for an all-zeros fill is acceptable).
- Parameters in `UPPER_SNAKE_CASE`; signals and instances in `lower_snake_case`.

## Sequential vs combinational

- **`always_ff @(posedge clk)`** for all sequential logic. Nonblocking (`<=`)
  assignments only.
- **`always_comb`** for combinational logic. Blocking (`=`) assignments only,
  and assign every output on every path to avoid inferred latches.
- One logical concern per `always` block. One driver per signal.
- **No inferred latches.** Give `always_comb` a default assignment at the top.

## Clocking and reset

- **Single clock domain by default.** Cross-domain inputs go through a
  synchronizer (`rtl/common/synchronizer.sv`).
- **No gated clocks and no derived/divided clocks as clocks.** To run logic
  slower, use a **clock enable** (`clk_en`) qualifying an `always_ff`, never a
  gated clock. Vintage ripple counters and dividers are modeled with enables.
- Reset is **active-low `reset_n`**, applied synchronously inside `always_ff`
  unless a part specifically needs async reset (document it if so).
- Make reset behavior **explicit where the real chip has a meaningful reset**.
  Where the real chip powers up undefined, choose a deterministic FPGA reset
  value and, where useful, expose the power-up value behind a parameter. Always
  document the divergence in the module header.

## Naming

- **Active-low signals end in `_n`**: `ce_n`, `oe_n`, `we_n`, `cs_n`,
  `reset_n`, `rd_n`, `wr_n`, `irq_n`.
- Names describe **function**, not type or vague role: `row_address`,
  `display_enable`, `counter_reload`, not `tmp`, `sig1`, `q2`.
- Preserve original chip terminology where it aids recognition (`MA`, `RA`,
  `DE`, `ORA`, `DDRA`, `CRA`) but also describe the behavior in modern terms in
  the header and in comments.

## Tri-state

- **No internal tri-state (`'z`) in synthesizable RTL.** A chip with tri-state
  data pins exposes:
  - `data_out` — the value the chip would drive,
  - `data_oe`  — 1 when the chip is actively driving (output enabled).
- A separate **simulation-only** wrapper may resolve a shared bus from multiple
  `data_out`/`data_oe` pairs. See [tri_state_modeling.md](tri_state_modeling.md).
- For bidirectional data pins (RAM common I/O), use internal `din`, `dout`,
  `dout_oe`.

## Datapath

- Prefer **counters, comparators, muxes, lookup tables, and explicit state
  machines**.
- **Avoid `*` and `/` in datapaths** unless there is a strong, documented reason
  (they map to DSP blocks / large logic). Constant power-of-two scaling is a
  shift.
- No `#` delays or other unsynthesizable timing in `rtl/`. **Delays appear only
  in testbenches.**

## Ripple counters (4000-series)

Ripple counters may be offered in two forms, clearly labeled:

1. A **behavioral / pin-faithful ripple-style reference** model for simulation
   only (each stage toggling on the previous stage's edge). Not for synthesis.
2. A **synchronous FPGA-safe** model: one clock, a clock enable, a binary
   counter whose bits are exposed as the stage outputs. This is the
   synthesizable default.

Document clearly when the synchronous model differs from analog/ripple behavior
(e.g. all stage outputs update on the same clock edge instead of rippling).

## Module header template

Every public module begins with this header:

```systemverilog
// ----------------------------------------------------------------------------
// <module_name> — <one-line description>
//
// Original chip/function : <e.g. 2716 2K x 8 EPROM, read path>
// FPGA modeling approach : <e.g. parameterized async ROM, $readmemh init>
// Differences from the IC: <key divergences: rails, tri-state, timing, power-up>
// Parameters             : <NAME — meaning; ...>
// Ports                  : <grouped summary; active-low noted>
// Reset behavior         : <what reset_n does; power-up assumptions>
// Synthesis notes        : <resource mapping, async vs sync read, no tri-state>
// Verification status    : <planned / basic / done; what the TB covers>
//
// Written from public behavioral descriptions. No copyrighted datasheet text or
// ROM contents are included. See docs/references.md.
// ----------------------------------------------------------------------------
```

## Example skeleton

```systemverilog
// header as above
module example_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             reset_n,    // active-low synchronous reset
    input  logic             clk_en,     // clock enable (no gated clocks)
    input  logic             load,
    input  logic [WIDTH-1:0] load_value,
    output logic [WIDTH-1:0] count,
    output logic             terminal_count
);
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            count <= '0;
        end else if (clk_en) begin
            if (load) count <= load_value;
            else      count <= count + 1'b1;
        end
    end

    always_comb begin
        terminal_count = (count == {WIDTH{1'b1}});
    end
endmodule
```
