#!/usr/bin/env bash

export GIT_ROOT="$(git rev-parse --show-toplevel)"
export WORK="$GIT_ROOT/work/uvm"
export SCRIPTS="$GIT_ROOT/verification/uvm/scripts"
export COMMON="$GIT_ROOT/verification/common"
mkdir -p "$WORK" && cd "$WORK"
ln -sf $SCRIPTS/mk/project.mk Makefile
ln -sf $COMMON/setup/setup_synopsys_eda.sh
source setup_synopsys_eda.sh
