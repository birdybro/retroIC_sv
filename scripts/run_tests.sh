#!/usr/bin/env bash
# run_tests.sh [category ...]
#
# Run all retroIC_sv test categories (or just the ones named on the command
# line). Exits non-zero if any category fails.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"

if [ "$#" -gt 0 ]; then
    categories=("$@")
else
    categories=()
    for d in "$root"/sim/*/; do
        c="$(basename "$d")"
        # Only categories that actually contain testbenches.
        if compgen -G "$d/tb_*.sv" > /dev/null; then
            categories+=("$c")
        fi
    done
fi

fail=0
for c in "${categories[@]}"; do
    echo "=== category: $c ==="
    if ! "$here/run_category.sh" "$c"; then
        fail=1
    fi
    echo
done

if [ "$fail" -ne 0 ]; then
    echo "RESULT: FAIL"; exit 1
fi
echo "RESULT: PASS"
