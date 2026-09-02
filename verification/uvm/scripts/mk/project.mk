##==============================================================================
## [Filename]       project.mk
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        -
## [Modified]       -
## [Description]    UVM project
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##==============================================================================

# ================================ DIRECTORIES =================================
# Project paths and directory hierarchy

GIT_DIR       := $(shell git rev-parse --show-toplevel)
TB_DIR        ?= $(GIT_DIR)/verification/uvm
COMMON_MK_DIR := $(GIT_DIR)/verification/common/mk

# =============================== CONFIGURATION ================================
# Project-specific defaults

# -------------------------------- COMPILE-TIME --------------------------------

# TIMESCALE               ?= 1ps/100fs
ENABLE_UVM              ?= true
# UVM_VERSION             ?= 1.2
ENABLE_DEBUG_DB         ?= true
# DEFINES                 ?=
# COMPILE_ARGS            ?=
# SIMV_NAME               ?= simv
ENABLE_CODE_COV_COMPILE ?= true
CODE_COV_TYPES_COMPILE  ?= line+cond+tgl
ENABLE_SVA_COMPILE      ?= false
UVCS_FILELIST           ?= -F $(TB_DIR)/uvcs.f
DPI_FILE                ?= $(COMMON_DPI_DIR)/lib/libdpi.so

# ---------------------------------- RUN-TIME ----------------------------------

# TEST                      ?= top_test
# VERBOSITY                 ?= UVM_MEDIUM
# SEED_MODE                 ?= fixed
# SEED                      ?= 5081996
ENABLE_UVM_RECORDING      ?= false
ENABLE_CODE_COV_RUN       ?= true
CODE_COV_TYPES_RUN        ?= line+cond+tgl
ENABLE_SVA_RUN            ?= false
DUMP_MODE                 ?= all
# JOB_NAME                  ?= debug
RUN_ARGS                  ?= +uvm_set_config_int=uvm_test_top.m_env.vsqr,m_cli_iter,300

# 			+uvm_set_config_int=uvm_test_top.m_env.vsqr,m_cli_cycles_asserted,120 \
# 			+uvm_set_config_int=uvm_test_top.m_env.vsqr,m_cli_cycles_deasserted,120

# ================================== INCLUDES ==================================

# Main framework
include $(COMMON_MK_DIR)/common.mk

# DPI
-include $(COMMON_MK_DIR)/dpi.mk

# Coverage
-include $(COMMON_MK_DIR)/cov.mk

# Regression Manager
# -include $(MK_DIR)/regression.mk

# ================================= HELP MENU ==================================

.PHONY: help
help: ## COMMON: Displays help message
	@printf "%s\n" "================================================================================"
	@printf "%s\n" "                                    PROJECT.MK                                  "
	@printf "%s\n" "================================================================================"
	@printf "%s\n" "Usage: make <target> [variables]"
	@printf "%s\n" "------------------------------------ TARGETS -----------------------------------"
	@grep -h -E '^help-[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "- make $(C_CYN)%-15s$(C_RST) %s\n", $$1, $$2}'
	@printf "%s\n" "================================================================================"
