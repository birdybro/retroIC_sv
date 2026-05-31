# scripts

Test-run scripts and helpers. The simulation path is **Verilator-first**; these
scripts build and run the self-checking testbenches per chip category and report
pass/fail.

## Layout (planned)

- `run_tests.sh` — top-level aggregator: runs every category and summarizes.
- `run_category.sh <category>` — build + run all `tb_*` for one category
  (`memory`, `cmos4000`, `intel82xx`, `motorola68xx`, `video`, `pal_gal`,
  `common`).
- `Makefile` — `make test`, `make memory`, `make cmos4000`, … targets wrapping
  the scripts.
- Python helpers (optional) — **only** for test orchestration or generating
  expected vectors / init hex files; never for implementing hardware behavior.

## Requirements

- [Verilator](https://www.veripool.org/verilator/) on `PATH`.
- A C++ toolchain (Verilator compiles the testbench harness).
- GNU Make.

## Conventions

- A test **passes** when its testbench prints `PASS` and exits 0; it **fails**
  on any non-zero exit. Scripts propagate the failure so CI catches it.
- Keep scripts POSIX-sh friendly where practical (the repo's interactive shell
  is fish, but scripts target `/bin/sh`/`bash` for portability and CI).
