# rtl/video

Video timing controllers. The first part here is the Motorola 6845 CRTC, the
workhorse CRT controller behind countless arcade boards, terminals, and home
computers.

## Contents (planned)

| File | Part | Scope (first pass) |
|---|---|---|
| `mc6845.sv` | 6845 CRTC | register file (R0–R17) + horizontal/vertical timing generation. |

## Outputs generated

- horizontal and vertical **display enable** (`DE`),
- **HSYNC** and **VSYNC**,
- **memory address** (`MA`) bus for fetching display data,
- **row address** (`RA`) for the character row scanline,
- **cursor** timing hooks.

Targets MC6845-compatible behavior first. Documentation of common variant
differences (HD6845, UM6845, 6545-style) comes later. Bus interface is the
Motorola `R/W` + `E` style — see
[docs/bus_interface_notes.md](../../docs/bus_interface_notes.md). Verification
checks register writes and the generated timing of a known simple video mode —
see [docs/verification_strategy.md](../../docs/verification_strategy.md).
