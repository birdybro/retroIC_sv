# rtl/intel82xx

Intel-style peripheral controllers with an `RD#`/`WR#`/`CS#` bus interface. See
[docs/bus_interface_notes.md](../../docs/bus_interface_notes.md) for the bus
convention and [docs/supported_chips.md](../../docs/supported_chips.md) for
status.

## Contents (planned)

| File | Part | Scope (first pass) |
|---|---|---|
| `i8255.sv` | 8255 PPI | ports A/B/C, control word, port-C bit set/reset, **mode 0**. Modes 1/2 are TODO. |
| `i8254.sv` | 8254 PIT | 3 counters, latch command, LSB/MSB/LSB-then-MSB access, **modes 0/2/3**, read-back command. Modes 1/4/5 TODO. |
| `i8253.sv` | 8253 PIT | 8254 behavior minus the read-back command. |
| `i8251.sv` | 8251 USART | later phase. |
| `i8212.sv` | 8212 latch/port | later phase. |

## Bus interface

```
input  logic [A-1:0] addr;      // register select (A1:A0)
input  logic [7:0]   data_in;
output logic [7:0]   data_out;
output logic         data_oe;   // no internal tri-state
input  logic         rd_n;
input  logic         wr_n;
input  logic         cs_n;
```

Strobes are synchronized and edge-detected against the FPGA `clk`; the model
stays single-clock with no gated clocks and no inferred latches.
