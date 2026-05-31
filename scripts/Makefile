# retroIC_sv test Makefile.
#
# Usage (from anywhere):
#   make -C scripts test           # run every category
#   make -C scripts memory         # run one category
#   make -C scripts clean          # remove Verilator build artifacts
#
# Requires Verilator 5.x on PATH.

SHELL := /bin/bash
HERE  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ROOT  := $(abspath $(HERE)/..)

CATEGORIES := common memory cmos4000 intel82xx motorola68xx video pal_gal

.PHONY: test $(CATEGORIES) clean

test:
	"$(HERE)/run_tests.sh"

$(CATEGORIES):
	"$(HERE)/run_category.sh" $@

clean:
	find "$(ROOT)/sim" -type d -name 'obj_*' -prune -exec rm -rf {} + 2>/dev/null || true
	find "$(ROOT)/sim" -type f \( -name 'build_*.log' -o -name 'run_*.log' \) -delete 2>/dev/null || true
	@echo "cleaned simulation artifacts"
