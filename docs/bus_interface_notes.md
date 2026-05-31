# Bus Interface Notes

Vintage support chips attach to one of two dominant CPU-bus styles. The models
present a clean, synchronous version of each while preserving externally visible
behavior. This doc explains the two styles and the common bus-interface signals
the peripheral models use.

## Intel-style bus (8080/8085/8086/Z80 family)

Characteristic signals:

- Separate **`RD#`** and **`WR#`** strobes (active low). A read happens when
  `RD#` is low and the chip is selected; a write when `WR#` is low.
- **`CS#`** chip select (active low), often produced by external address decode.
- A small **address** field selecting an internal register (`A1:A0` on the 8255,
  `A1:A0` on the 8253/8254).
- 8-bit bidirectional **data** bus.

Our models expose this as:

```
input  logic [A-1:0] addr;       // register select
input  logic [7:0]   data_in;    // CPU → chip (write data)
output logic [7:0]   data_out;   // chip → CPU (read data)
output logic         data_oe;    // 1 when chip drives data_out
input  logic         rd_n;       // active-low read strobe
input  logic         wr_n;       // active-low write strobe
input  logic         cs_n;       // active-low chip select
```

A register write is recognized on the (synchronous) assertion of
`cs_n==0 && wr_n==0`; a read presents `data_out` and asserts `data_oe` while
`cs_n==0 && rd_n==0`. Internally the strobes are sampled/edge-detected against
the FPGA clock so the model stays single-clock and glitch-free.

Chips in this style here: **8255 PPI**, **8253/8254 PIT** (later 8251, 8212).

## Motorola-style bus (6800/6809/6502 family)

Characteristic signals:

- A single **`R/W`** line (high = read, low = write) instead of separate strobes.
- An enable/clock **`E`** (the 6800-family φ2-derived enable) that qualifies the
  access; data is transferred on `E`.
- One or more **chip selects** (`CS`, `CS#`) from address decode.
- **Register-select** address lines (`RS1:RS0` on the 6821, `RS` on the 6845).
- 8-bit bidirectional **data** bus.

Our models expose this as:

```
input  logic [A-1:0] rs;         // register select
input  logic [7:0]   data_in;    // CPU → chip
output logic [7:0]   data_out;   // chip → CPU
output logic         data_oe;    // 1 when chip drives data_out
input  logic         rw;         // 1 = read, 0 = write
input  logic         cs;         // chip select(s), combined
input  logic         e;          // E / enable strobe
```

The model treats `E` as a clock-enable-style qualifier sampled against the FPGA
clock (not as a clock — no gated clocks). A write commits when the chip is
selected, `rw==0`, and `E` is active; a read drives `data_out`/`data_oe` while
selected, `rw==1`, and `E` active.

Chips in this style here: **6821 PIA**, **6840 PTM**, **6845 CRTC** (later 6850).

## Why we re-clock the bus

The real chips are asynchronous to a degree the FPGA fabric dislikes. To stay
synth-safe (single clock, no gated clocks, no latches), the models:

1. Synchronize the external strobes/enables to the FPGA `clk`.
2. Edge-detect the active transition to produce a one-cycle internal
   write-commit / read-data-valid pulse.
3. Drive `data_out`/`data_oe` combinationally from the selected register while
   the read condition holds.

This preserves the *visible* register-access behavior (what value you read, when
a write takes effect) while making the logic deterministic. Where exact cycle
timing matters for a core, the model header documents the assumption and the
testbench checks it. See [coding_style.md](coding_style.md) and
[tri_state_modeling.md](tri_state_modeling.md).

## Interrupts

- Intel-style parts here are mostly polled; where relevant, status bits are
  read through the data bus.
- Motorola-style parts use an active-low, open-drain **`IRQ#`** wired-OR on the
  real board. We expose `irq_n` as a normal output (asserted low when any
  enabled interrupt source is active); the board-level wired-OR becomes an AND of
  `irq_n` signals (or an OR of internal request signals) in the integrator,
  following the no-internal-tri-state rule.
