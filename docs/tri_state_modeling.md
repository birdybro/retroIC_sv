# Tri-State Modeling

## The problem

Vintage chips share a data bus by tri-stating their output pins: only the
selected device drives, everyone else goes high-impedance (`Z`). In board-level
schematics this is the natural idiom.

Inside an FPGA it is the wrong idiom. Modern FPGA fabric has **no internal
tri-state buses** — internal `Z` either gets synthesized into a mux by the tool
(if you're lucky) or causes contention/`X` and non-deterministic behavior (if
you're not). Tri-state is only real on actual device I/O pins. So:

> **retroIC_sv RTL never uses internal `'z`.** Models that have tri-state pins on
> the real chip expose an explicit output-enable instead.

## The convention

A chip with tri-state data outputs presents:

| Signal | Meaning |
|---|---|
| `data_out` | the value the chip *would* drive onto the bus |
| `data_oe`  | `1` when the chip is actively driving (output enabled), else `0` |

`data_oe` is the synthesized equivalent of "this pin is not high-Z right now."
It is asserted only when the chip is selected and output-enabled (and, for RAM,
not in a write cycle). Consumers must ignore `data_out` whenever `data_oe == 0`.

For **bidirectional** pins (RAM common I/O, peripheral data bus) the internal
names are:

| Signal | Direction (chip's view) | Meaning |
|---|---|---|
| `din`      | input  | data sampled from the bus during a write/CPU-write |
| `dout`     | output | data the chip would drive during a read/CPU-read |
| `dout_oe`  | output | `1` when the chip drives `dout` |

## Resolving a shared bus

Because each model exposes `data_out`/`data_oe`, the **integrator** builds the
bus with a mux, not with tri-state. Typical synthesizable pattern:

```systemverilog
// Read-data mux: select whichever device is currently driving.
always_comb begin
    cpu_data_in = 8'hFF;                  // idle/pulled-up bus default
    if (rom_oe)  cpu_data_in = rom_dout;
    if (ram_oe)  cpu_data_in = ram_dout;
    if (ppi_oe)  cpu_data_in = ppi_dout;
end
```

At most one `*_oe` should be high in correct operation; the priority chain above
is a safe default and easy to assert against in a testbench (see
[verification_strategy.md](verification_strategy.md)).

### FPGA top-level pins

If a model's bus must reach a *real* bidirectional FPGA pin (e.g. talking to an
off-chip device), do the tri-state **once, at the top level**, on the I/O buffer:

```systemverilog
assign data_pin = dout_oe ? dout : 8'bz;   // only at a true device pad
assign din      = data_pin;
```

This is the single sanctioned place for `'z`, and it lives in the top-level
wrapper, not in the reusable model.

## Optional simulation-only bus resolver

For convenience, a model category may provide a **simulation-only** wrapper that
takes several `data_out`/`data_oe` pairs and produces a resolved bus value
(including `X` on contention, so tests can catch double-drive bugs). Such a
wrapper is clearly marked simulation-only and is **not** part of the synthesizable
model. The synthesizable path always uses the mux pattern above.
