# rtl/motorola68xx

Motorola-style peripheral controllers with an `R/W` + `E` (enable) bus
interface. See [docs/bus_interface_notes.md](../../docs/bus_interface_notes.md)
for the bus convention and
[docs/supported_chips.md](../../docs/supported_chips.md) for status.

The 6845 CRTC lives in [`rtl/video/`](../video/) even though it is a 68xx-family
part, because it is grouped with the video models.

## Contents (planned)

| File | Part | Scope (first pass) |
|---|---|---|
| `m6821.sv` | 6821 PIA | ORA/ORB, DDRA/DDRB, CRA/CRB; CA1/CA2/CB1/CB2 interrupt subset. Full handshake modes TODO. |
| `m6840.sv` | 6840 PTM | 3 timer channels, common modes, IRQ, prescaler. Less-common gating modes TODO. |
| `m6850.sv` | 6850 ACIA | later phase. |

## Bus interface

```
input  logic [A-1:0] rs;        // register select
input  logic [7:0]   data_in;
output logic [7:0]   data_out;
output logic         data_oe;   // no internal tri-state
input  logic         rw;        // 1 = read, 0 = write
input  logic         cs;        // combined chip select(s)
input  logic         e;         // E / enable strobe (clock-enable style)
output logic         irq_n;     // active-low interrupt request
```

`E` is treated as a clock-enable-style qualifier sampled against the FPGA `clk`,
never as a clock. The board-level wired-OR of `IRQ#` becomes explicit logic in
the integrator (no internal tri-state).
