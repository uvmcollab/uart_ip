#!/usr/bin/env tcsh

setenv GIT_ROOT `git rev-parse --show-toplevel`
setenv WORK $GIT_ROOT/work/uvm
setenv SCRIPTS $GIT_ROOT/verification/uvm/scripts
setenv COMMON $GIT_ROOT/verification/common
mkdir -p $WORK && cd $WORK
ln -sf $SCRIPTS/mk/project.mk Makefile
ln -sf $COMMON/setup/setup_synopsys_eda.tcsh
source setup_synopsys_eda.tcsh
