# rtl/memory

Parallel ROM/EPROM and static RAM models, built on two parameterized base
modules. See [docs/memory_models.md](../../docs/memory_models.md) for the full
design rationale and FPGA ROM-loading flows.

## Base modules

- `generic_async_rom.sv` — parameterized ROM. Params: `ADDR_WIDTH`,
  `DATA_WIDTH`, `INIT_FILE`, `REGISTER_OUTPUT` (async vs registered read).
- `generic_sram.sv` — parameterized SRAM. Params: `ADDR_WIDTH`, `DATA_WIDTH`,
  `BYTE_ENABLE`, `SYNC_READ`. Synchronous write; async or sync read. Uses
  `din`/`dout`/`dout_oe`, never internal tri-state.

## EPROM wrappers

`eprom_2708`, `eprom_2716`, `eprom_2732`, `eprom_2764`, `eprom_27128`,
`eprom_27256`, `eprom_27512` — thin shells fixing the device size and exposing
active-low `ce_n` / `oe_n` (and device-specific pins).

## SRAM wrappers

`sram_2114` (1K×4), `sram_6116` (2K×8), `sram_6264` (8K×8), `sram_62256`
(32K×8) — fix the device size and expose `ce_n`/`oe_n`/`we_n` (and the 6264's
dual chip selects).

## Notes

- **No ROM contents are shipped here.** `INIT_FILE` is for your own images and
  for tiny synthetic test vectors only.
- Async read → distributed/LUT RAM on FPGA; registered read → M10K block RAM.
  Pick per ROM size; see [docs/memory_models.md](../../docs/memory_models.md).
