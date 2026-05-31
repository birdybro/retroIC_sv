# Supported Chips

Status keys: **planned** (not yet implemented), **in progress**, **basic**
(core behavior implemented + tested, some modes/features deferred), **done**
(target behavior implemented + tested).

FPGA modeling approach is summarized per chip; see the module header comment and
the linked docs for detail. "Caveats" calls out the most important divergences
from the physical part.

## Parallel ROM / EPROM

| Chip | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| 2708 | ROM/EPROM | planned | 1K×8 EPROM (1Kx8, multi-rail) | generic async ROM wrapper, 10-bit addr | Real part needs −5/+12 V rails and has 3 chip-selects; we model the single logical `ce_n`/`oe_n` read path only. |
| 2716 | ROM/EPROM | planned | 2K×8 EPROM | generic async ROM, 11-bit addr, `ce_n`+`oe_n` | Single +5 V 2716 assumed. No programming model. |
| 2732 | ROM/EPROM | planned | 4K×8 EPROM | generic async ROM, 12-bit addr | `oe_n`/`ce_n` combined on real `OE/Vpp` pin; modeled as separate `oe_n`. |
| 2764 | ROM/EPROM | planned | 8K×8 EPROM | generic async ROM, 13-bit addr | Has `ce_n` + `oe_n` + `pgm_n`; we model read path. |
| 27128 | ROM/EPROM | planned | 16K×8 EPROM | generic async ROM, 14-bit addr | As 2764. |
| 27256 | ROM/EPROM | planned | 32K×8 EPROM | generic async ROM, 15-bit addr | As 2764. |
| 27512 | ROM/EPROM | planned | 64K×8 EPROM | generic async ROM, 16-bit addr | `oe_n`/Vpp shared on real part; modeled as `oe_n`. |
| generic_async_rom | ROM/EPROM | planned | parameterized ROM | params: ADDR_WIDTH, DATA_WIDTH, INIT_FILE, REGISTER_OUTPUT | Base for all EPROM wrappers; `$readmemh` init. See [memory_models.md](memory_models.md). |

## Static RAM

| Chip | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| 2114 | SRAM | planned | 1K×4 SRAM | generic SRAM, 10-bit addr, 4-bit data | Nibble-wide; common-I/O data pins → `din`/`dout`/`dout_oe`. |
| 6116 | SRAM | planned | 2K×8 SRAM | generic SRAM, 11-bit addr, 8-bit data | `ce_n`+`oe_n`+`we_n`. |
| 6264 | SRAM | planned | 8K×8 SRAM | generic SRAM, 13-bit addr, 8-bit data | Two chip selects (`cs1_n`, `cs2`) on real part; modeled as combined enable. |
| 62256 | SRAM | planned | 32K×8 SRAM | generic SRAM, 15-bit addr, 8-bit data | As 6116/6264. |
| generic_sram | SRAM | planned | parameterized SRAM | params: ADDR_WIDTH, DATA_WIDTH, byte enable, sync write, async/sync read | `dout_oe` instead of tri-state. Async read = distributed/LUT RAM on FPGA; sync read = M10K. See [memory_models.md](memory_models.md). |

## 4000/4500-series CMOS logic

| Chip | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| CD4013 | CMOS4000 | planned | dual D flip-flop w/ set/reset | two clocked D-FFs, sync clock-enable on real edge | Async `set`/`reset` modeled; real part is level (not edge) on S/R. |
| CD4020 | CMOS4000 | planned | 14-stage ripple counter | sync counter + clock enable; optional ripple reference | Ripple delays not modeled in sync form; see [coding_style](coding_style.md). |
| CD4040 | CMOS4000 | planned | 12-stage ripple counter | sync counter + clock enable; optional ripple reference | Q0..Q11 exposed; clears on `reset`. |
| CD4051 | CMOS4000 | planned | 8:1 analog mux/demux | **digital** 8:1 mux + 1:8 demux with `inhibit` | No analog resistance/bidirectional analog; digital direction selected by use. |
| CD4052 | CMOS4000 | planned | dual 4:1 analog mux/demux | **digital** dual 4:1 mux | Digital model only. |
| CD4053 | CMOS4000 | planned | triple 2:1 analog mux/demux | **digital** triple 2:1 mux | Digital model only. |
| CD4066 | CMOS4000 | planned | quad bilateral switch | **digital** quad switch as enable/mux (`a`→`y` when `ctrl`) | No analog Ron, no true bidirectional analog. Models pass/block. |
| CD4069 | CMOS4000 | planned | hex inverter | six combinational inverters | Trivial; included for completeness/decode glue. |
| CD4511 | CMOS4000 | planned | BCD→7-seg latch/decoder/driver | latch + BCD→segment LUT, `lt_n`/`bl_n`/`le` | Active-high segment outputs; no LED current drive modeled. |
| CD4520 | CMOS4000 | planned | dual 4-bit binary counter | two sync up-counters, clock enable, `reset` | Real part has dual clock/enable edge options; modeled with CE + rising edge. |
| CD4538 | CMOS4000 | planned | dual precision monostable | **digital** one-shot: tick-count pulse width, retriggerable param | No RC; pulse length in clock ticks. See [coding_style](coding_style.md). |

## Intel-style peripherals

| Chip | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| 8255 | Intel82xx | planned | programmable peripheral interface (PPI) | bus FSM + ports A/B/C, control word, port-C bit set/reset | Mode 0 first; modes 1/2 (strobed/bidirectional) are TODO. |
| 8253 | Intel82xx | planned | programmable interval timer (PIT) | 3 counters, latch cmd, LSB/MSB access | Modes 0/2/3 first; no read-back command (8253 lacks it). |
| 8254 | Intel82xx | planned | programmable interval timer (PIT) | 8253 + read-back command + status | Modes 0/2/3 first; modes 1/4/5 TODO. |
| 8251 | Intel82xx | planned (later) | USART | bus FSM + Tx/Rx shift, mode/command words | Later phase. |
| 8212 | Intel82xx | planned (later) | 8-bit latch / I/O port | clocked latch + strobe logic | Later phase. |

## Motorola-style peripherals

| Chip | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| 6821 | Motorola68xx | planned | peripheral interface adapter (PIA) | ORA/ORB, DDRA/DDRB, CRA/CRB; CA1/CA2/CB1/CB2 IRQ subset | Output/input + basic interrupt modes first; full CA2/CB2 handshake TODO. |
| 6840 | Motorola68xx | planned | programmable timer module (PTM) | 3 timer channels, common modes, IRQ | Continuous + single-shot modes first; less-common gating modes TODO. |
| 6850 | Motorola68xx | planned (later) | ACIA (serial) | bus FSM + Tx/Rx, status/control | Later phase. |

## Video

| Chip | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| 6845 | Video | planned | CRT controller (CRTC) | register file + H/V counters → DE, HSYNC, VSYNC, MA, RA, cursor | MC6845-compatible first; HD6845/UM6845/6545 variant notes later. See [bus_interface_notes.md](bus_interface_notes.md). |

## PAL/GAL/PROM replacement

| Module | Category | Status | Original function | FPGA modeling approach | Notes / caveats |
|---|---|---|---|---|---|
| pal_comb_decode | PAL/GAL | planned | combinational decode PAL | parameterized comb template (sum-of-products style) | Reproduce board equations, not PAL silicon. See [pal_gal_replacement.md](pal_gal_replacement.md). |
| pal_registered | PAL/GAL | planned | registered/stateful PAL (e.g. 16R8) | clocked outputs + comb next-state | |
| prom_lut | PAL/GAL | planned | small bipolar PROM (e.g. 82S123/82S129) | LUT via `$readmemh`, combinational or registered | For video timing / color PROMs. |
| examples | PAL/GAL | planned | board decode logic | worked Z80/6809/arcade/video examples | In [`examples/`](../examples/). |
