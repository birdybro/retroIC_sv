# Memory Models

How retroIC_sv models parallel ROM/EPROM and static RAM, and how to load real
contents on an FPGA. Background on FPGA memory inference is in
[`hdl-coding-guidelines/30-memory-inference-cyclone-v.md`](../hdl-coding-guidelines/30-memory-inference-cyclone-v.md).

## Generic building blocks

Everything is built on two parameterized base modules:

- **`generic_async_rom`** — read-only, address-in / data-out.
  - Parameters: `ADDR_WIDTH`, `DATA_WIDTH`, `INIT_FILE`, `REGISTER_OUTPUT`.
  - `INIT_FILE` is loaded with `$readmemh` into the storage array.
  - `REGISTER_OUTPUT = 0` → **asynchronous (combinational) read**: `data_out`
    reflects `addr` with no clock. This matches the vintage part's async read
    and is convenient, but on FPGA it infers **LUT / distributed memory**, not a
    block RAM. Good for small ROMs (decoders, small char sets).
  - `REGISTER_OUTPUT = 1` → **synchronous read**: `data_out` is registered, one
    clock of latency. This is the form Quartus infers into **M10K** block RAM
    and is what you want for large ROMs (character/tile/program ROM).
- **`generic_sram`** — read/write static RAM.
  - Parameters: `ADDR_WIDTH`, `DATA_WIDTH`, `BYTE_ENABLE` (where useful),
    `SYNC_READ` (async vs sync read).
  - **Synchronous write** always (write on the clock edge under `we`).
  - `SYNC_READ = 0` → asynchronous/combinational read (distributed RAM on FPGA),
    closest to the real async SRAM.
  - `SYNC_READ = 1` → registered read (M10K), one clock of read latency.
  - Bidirectional common-I/O parts are modeled with internal `din`, `dout`, and
    `dout_oe` — never internal tri-state (see
    [tri_state_modeling.md](tri_state_modeling.md)).

## Chip-specific wrappers

Each EPROM/SRAM wrapper is a thin shell over the generic base that:

- fixes `ADDR_WIDTH` / `DATA_WIDTH` to the real device size,
- exposes the real device's **active-low control pins** (`ce_n`, `oe_n`,
  `we_n`, chip selects),
- documents which physical pins/rails are *not* modeled.

Example sizes:

| Wrapper | Words × bits | ADDR_WIDTH | DATA_WIDTH |
|---|---|---|---|
| `eprom_2716` | 2K × 8 | 11 | 8 |
| `eprom_2732` | 4K × 8 | 12 | 8 |
| `eprom_2764` | 8K × 8 | 13 | 8 |
| `eprom_27128` | 16K × 8 | 14 | 8 |
| `eprom_27256` | 32K × 8 | 15 | 8 |
| `eprom_27512` | 64K × 8 | 16 | 8 |
| `sram_2114` | 1K × 4 | 10 | 4 |
| `sram_6116` | 2K × 8 | 11 | 8 |
| `sram_6264` | 8K × 8 | 13 | 8 |
| `sram_62256` | 32K × 8 | 15 | 8 |

### Control-pin modeling

- **Chip enable / output enable.** `ce_n` low selects the device; `oe_n` low
  enables the output drivers. `data_oe` is asserted only when the device is
  selected *and* output-enabled (and, for RAM, not writing). When `data_oe` is
  low the integrating bus wrapper must not sample `data_out` from this device.
- **Multiple selects.** Parts like the 6264 have two chip selects (`CS1#`,
  `CS2`). The wrapper presents the real pins and ANDs them into one internal
  select, documented in the header.
- **Shared OE/Vpp pins.** On several EPROMs the programming voltage shares a pin
  with `OE`. We model only the **read** path; programming is out of scope.

## ROM/RAM initialization on FPGA

The models read initial contents with `$readmemh(INIT_FILE, mem)`. Supported
flows:

1. **Generic simulation (`$readmemh`).** Point `INIT_FILE` at a hex file (one
   byte per line, hex). Works in Verilator and other simulators, and is also
   recognized by Quartus/Vivado synthesis to preload block RAM at configuration
   time. Keep the path relative to the project/synthesis root so the synthesizer
   finds it (a common bug is a sim-relative path that is empty on hardware).
2. **MiSTer-style ROM loading.** In a MiSTer core, ROM contents usually arrive
   at runtime over the HPS→FPGA `ioctl` download interface and are written into
   a RAM/ROM block. For that flow, instantiate `generic_sram` (or a
   dual-port variant) and drive its write port from the download logic instead
   of relying on `INIT_FILE`. The `INIT_FILE` path is then used only for
   simulation. This keeps the repo free of copyrighted ROM images.
3. **Vendor memory init files.** Quartus `.mif`/`.hex` and Vivado `.coe`/`.mem`
   can initialize inferred block RAM. If you prefer those over `$readmemh`,
   generate them from your ROM image and reference them via the vendor
   attribute; the RTL template is unchanged. Only the init mechanism differs.

> **No ROM contents are shipped in this repository.** The only `.hex` files
> present are tiny synthetic vectors used by the testbenches.

## Power-up state

Real SRAM powers up undefined. The models reset their storage deterministically
only if you ask: by default storage is left as-loaded (`INIT_FILE`) or
zero-initialized in simulation. Where deterministic power-up matters for a core,
preload via `INIT_FILE` or clear via the download/write path. The header of each
wrapper states its power-up assumption.
