#!/usr/bin/env bash
# run_category.sh <category>
#
# Build and run every self-checking testbench (sim/<category>/tb_*.sv) with
# Verilator, compiling the matching rtl/<category> sources plus rtl/common.
# A test passes when its binary prints PASS and exits 0. Exits non-zero if any
# build or test fails.
set -uo pipefail

cat="${1:?usage: run_category.sh <category>}"
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
simdir="$root/sim/$cat"
rtldir="$root/rtl/$cat"

if [ ! -d "$simdir" ]; then
    echo "no sim directory for category '$cat'"; exit 1
fi

# Verilator warning suppressions: these are stylistic for this library
# (parameterized widths, optionally-used clk/ports under generate, etc.).
VFLAGS=(--binary --timing -Wall
        -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM
        -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-VARHIDDEN
        -Wno-fatal)

# Gather RTL sources (package first for clean elaboration order).
rtl_srcs=()
[ -f "$root/rtl/common/retro_ic_pkg.sv" ] && rtl_srcs+=("$root/rtl/common/retro_ic_pkg.sv")
for f in "$root"/rtl/common/*.sv; do
    [ "$f" = "$root/rtl/common/retro_ic_pkg.sv" ] && continue
    [ -e "$f" ] && rtl_srcs+=("$f")
done
for f in "$rtldir"/*.sv; do
    [ -e "$f" ] && rtl_srcs+=("$f")
done

fail=0
ran=0
shopt -s nullglob
for tb in "$simdir"/tb_*.sv; do
    name="$(basename "$tb" .sv)"
    ran=$((ran+1))
    (
        cd "$simdir" || exit 1
        if ! verilator "${VFLAGS[@]}" \
                -I"$root/rtl/common" -I"$rtldir" \
                "${rtl_srcs[@]}" "$tb" \
                --top-module "$name" --Mdir "obj_$name" -o "$name" \
                > "build_$name.log" 2>&1; then
            echo "BUILD FAIL: $name (see sim/$cat/build_$name.log)"
            tail -n 20 "build_$name.log"
            exit 1
        fi
        if ! "./obj_$name/$name" > "run_$name.log" 2>&1; then
            echo "TEST FAIL: $name"
            cat "run_$name.log"
            exit 1
        fi
        grep -q "^PASS" "run_$name.log" || { echo "TEST FAIL (no PASS): $name"; cat "run_$name.log"; exit 1; }
        echo "ok: $name"
    ) || fail=1
done
shopt -u nullglob

if [ "$ran" -eq 0 ]; then
    echo "no testbenches found in sim/$cat"; exit 0
fi
if [ "$fail" -ne 0 ]; then
    echo "category '$cat': FAILURES"; exit 1
fi
echo "category '$cat': all $ran test(s) passed"
