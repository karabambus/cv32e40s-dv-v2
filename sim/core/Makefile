###############################################################################
#
# Copyright 2020 OpenHW Group
#
# Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://solderpad.org/licenses/
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################
#
# Makefile for the CV_CORE "core" testbench.  Substantially modified from the
# Makefile original for the RI5CY testbench.
#
###############################################################################
#
# Copyright 2019 Claire Wolf
# Copyright 2019 Robert Balas
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# Original Author: Robert Balas (balasr@iis.ee.ethz.ch)
#
###############################################################################

# "Constants"
MAKE           = make
MAKE_DIR       = $(PWD)
MAKE_PATH     := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
COREV_PROJ     = cv32
CV32E40S_DV    = $(abspath $(MAKE_PATH)/../../)
CORE_V_VERIF   = $(CV32E40S_DV)
DATE           = $(shell date +%F)
WAVES          = 0

CV_CORE       ?= CV32E40S
CV_CORE_LC     = $(shell echo $(CV_CORE) | tr A-Z a-z)
CV_CORE_UC     = $(shell echo $(CV_CORE) | tr a-z A-Z)

# Compile compile flags for all simulators
SV_CMP_FLAGS =

# Default "custom test-program"
CUSTOM_PROG  ?= requested_csr_por
TEST         ?= hello-world

CV_SW_TOOLCHAIN ?= /opt/riscv
CV_SW_PREFIX    ?= riscv64-unknown-elf-
CV_SW_MARCH     ?= rv32imc_zicsr_zifencei

###############################################################################
# Common Makefiles:
#  -Variables for RTL and other dependencies (e.g. RISCV-DV)
include ../ExternalRepos.mk
#  -Core Firmware and the RISCV GCC Toolchain (SDK)
include $(CORE_V_VERIF)/mk/Common.mk

# vsim configuration
VVERSION  = "10.7b"

VLIB      = vlib
VWORK     = work

VLOG          = vlog
VLOG_FLAGS    = -pedanticerrors -suppress 2577 -suppress 2583
VLOG_LOG      = vloggy

VOPT          = vopt
VOPT_FLAGS    = -debugdb -fsmdebug -pedanticerrors +acc #=mnprft

VSIM              = vsim
VSIM_HOME         = /usr/pack/modelsim-$(VVERSION)-kgf/questasim
VSIM_FLAGS       ?=  # user defined
ALL_VSIM_FLAGS    = $(VSIM_FLAGS)
VSIM_DEBUG_FLAGS  = -debugdb
VSIM_GUI_FLAGS    = -gui -debugdb
VSIM_SCRIPT_DIR	  = ../tools/vsim
VSIM_SCRIPT       = $(VSIM_SCRIPT_DIR)/vsim.tcl

# vcs configuration (hopelessly out of date)
VCS_VERSION             = O-2018.09-SP1-1
VCS_HOME                = /opt/synopsys/vcs-mx/$(VCS_VERSION)
VCS                     = vcs
VCS_FLAGS              ?= # user defined
ALL_VCS_FLAGS           = $(VCS_FLAGS)
VCS_SCRIPT_DIR          = ../tools/vcs
VCS_SCRIPT              = $(VCS_SCRIPT_DIR)/vcs_batch.tcl
VCS_SCRIPT_GUI          = $(VCS_SCRIPT_DIR)/vcs.tcl
SIMV                    = ./simv

# dsim is the Metrics Technologies SystemVerilog simulator  (https://metrics.ca/)
DSIM                    = dsim
DSIM_HOME               = /tools/Metrics/dsim
DSIM_CMP_FLAGS          = +define+CORE_TB+COREV_ASSERT_OFF -timescale 1ns/1ps $(SV_CMP_FLAGS) -suppress MultiBlockWrite +define+CV32E40S_APU_TRACE
DSIM_RUN_FLAGS          = -write-sql
DSIM_UVM_ARGS           = +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv
DSIM_RESULTS           ?= $(PWD)/dsim_results
DSIM_WORK              ?= $(DSIM_RESULTS)/dsim_work
DSIM_IMAGE              = dsim.out

ifneq (${WAVES}, 0)
  DSIM_CMP_FLAGS += +acc+b
  DSIM_DMP_FILE  ?= dsim.fst
  DSIM_RUN_FLAGS += -waves $(DSIM_DMP_FILE) +disass +disass_display
  # Verilator wave support (FST)
  VERI_TRACE      = --trace-fst
  VERI_RUN_FLAGS += +waves
  VERI_WAVE_CMD   = +wave_file=cv32e40s.fst
endif

# xrun is the Cadence xcelium SystemVerilog simulator (https://cadence.com/)
XRUN              = xrun
XRUN_FLAGS        = -clean -smartorder -sv -top worklib.tb_top -timescale 1ns/1ps +define+CV32E40S_APU_TRACE -uvmhome CDNS-1.2-ML
XRUN_DIR          = xcelium.d

# verilator configuration
VERILATOR           = verilator
VERI_FLAGS         +=
VERI_COMPILE_FLAGS += -Wno-COMBDLY -Wno-MULTIDRIVEN -Wno-BLKANDNBLK -Wno-lint --Wno-UNOPTFLAT -Wno-MODDUP -Wno-SYMRSVDWORD +define+COREV_ASSERT_OFF $(SV_CMP_FLAGS)
VERI_TRACE         ?=
VERI_OBJ_DIR       ?= cobj_dir
VERI_LOG_DIR       ?= cobj_dir/logs
VERI_CFLAGS        += -O2

#riviera configuration

ALIB      = "vlib"
AWORK     = work

ALOG          = vlog
ALOG_DEBUG    = -dbg
ALOG_FLAGS    =
ALOG_UVM      = -uvmver 1.2

ASIM              = vsim
ASIM_HOME         = $(ALDEC_PATH)
ASIM_FLAGS       ?=  # user defined
ALL_ASIM_FLAGS    = $(ASIM_FLAGS)
ASIM_DEBUG_FLAGS  = -dbg
ASIM_GUI_FLAGS    = -gui

VERI_CUSTOM          = $(CV32E40S_DV)/tests/programs/custom
VERI_CUSTOM_RELPATH  = ../../tests/programs/custom

# TB source files for the CV32E core
TBSRC_HOME  := $(CV32E40S_DV)/tb
TBSRC_TOP   := $(TBSRC_HOME)/core/tb_top.sv
TBSRC_CORE  := $(TBSRC_HOME)/core
TBSRC_PKG   := $(TBSRC_CORE)/tb_riscv/include/perturbation_defines.sv
TBSRC       := $(TBSRC_CORE)/tb_top.sv \
               $(TBSRC_CORE)/cv32e40s_tb_wrapper.sv \
               $(TBSRC_CORE)/mm_ram.sv \
               $(TBSRC_CORE)/dp_ram.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_random_stall.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_random_interrupt_generator.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_rvalid_stall.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_gnt_stall.sv

#/tb_riscv/riscv_rvalid_stall.sv

RTLSRC_VLOG_TB_TOP	:= $(basename $(notdir $(TBSRC_TOP)))
RTLSRC_VOPT_TB_TOP	:= $(addsuffix _vopt, $(RTLSRC_VLOG_TB_TOP))

TBSRC_VERI  := $(TBSRC_CORE)/tb_top.sv \
               $(TBSRC_CORE)/cv32e40s_tb_wrapper.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_rvalid_stall.sv \
               $(TBSRC_CORE)/tb_riscv/riscv_gnt_stall.sv \
               $(TBSRC_CORE)/mm_ram.sv \
               $(TBSRC_CORE)/dp_ram.sv

# RTL source files for the CV32E core
# DESIGN_RTL_DIR is used by CV_CORE_MANIFEST file
CV_CORE_PKG           := $(CORE_V_VERIF)/core-v-cores/$(CV_CORE_LC)
CV_CORE_RTLSRC_INCDIR := $(CV_CORE_PKG)/rtl/include
CV_CORE_RTLSRC_PKG    := $(CV_CORE_PKG)/rtl/fpnew/src/fpnew_pkg.sv \
				$(addprefix $(CV_CORE_RTLSRC_INCDIR)/,\
				CV_CORE_apu_core_package.sv CV_CORE_defines.sv \
				CV_CORE_tracer_defines.sv)
CV_CORE_RTLSRC  := $(filter-out $(CV_CORE_PKG)/rtl/$(CV_CORE_LC)_register_file_latch.sv, \
                $(wildcard $(CV_CORE_PKG)/rtl/*.sv))
# FIXME: temporarily using a local manifest for the core.
#        This is BAD PRACTICE and will be fixed with
#        https://github.com/openhwgroup/CV_CORE/pull/421 is resolved.
CV_CORE_MANIFEST    := $(CV_CORE_PKG)/cv32e40s_manifest.flist
export DESIGN_RTL_DIR = $(CV_CORE_PKG)/rtl

# Shorthand rules for convience
CV_CORE_pkg: clone_$(CV_CORE_LC)_rtl

tbsrc_pkg: $(TBSRC_PKG)

tbsrc: $(TBSRC)

###############################################################################

SIMULATOR ?= vcs

.PHONY: hello-world
hello-world: $(SIMULATOR)-hello-world

.PHONY: cv32_riscv_tests
cv32_riscv_tests: $(SIMULATOR)-cv32_riscv_tests

.PHONY: cv32_riscv_tests-gui
cv32_riscv_tests-gui: $(SIMULATOR)-cv32_riscv_tests-gui

.PHONY: cv32_riscv_compliance_tests
cv32_riscv_compliance_tests: $(SIMULATOR)-cv32_riscv_compliance_tests

.PHONY: cv32_riscv_compliance_tests-gui
cv32_riscv_compliance_tests-gui: $(SIMULATOR)-cv32_riscv_compliance_tests-gui

.PHONY: firmware
firmware: $(SIMULATOR)-firmware

.PHONY: firmware-gui
firmware-gui: $(SIMULATOR)-firmware-gui

.PHONY: unit-test
unit-test: $(SIMULATOR)-unit-test

.PHONY: unit-test-gui
unit-test-gui: $(SIMULATOR)-unit-test-gui

# assume verilator if no target chosen
.DEFAULT_GOAL := sanity-veri-run

all: clean_all sanity-veri-run dsim-sanity

###############################################################################
# Metrics DSIM
.PHONY: dsim-comp dsim-comp-rtl-only

MKDIR_P = mkdir -p

mk_results:
	$(MKDIR_P) $(DSIM_RESULTS)
	$(MKDIR_P) $(DSIM_WORK)

# Metrics dsim compile targets
dsim-comp: mk_results CV_CORE_pkg tbsrc_pkg tbsrc
		cd $(DSIM_RESULTS) && \
		$(DSIM) \
		$(DSIM_CMP_FLAGS) \
		$(DSIM_UVM_ARGS) \
		-f $(CV_CORE_MANIFEST) \
		$(TBSRC_PKG) \
		$(TBSRC) \
		-work $(DSIM_WORK) \
		-genimage $(DSIM_IMAGE)

dsim-comp-rtl-only: mk_results $(CV_CORE_PKG)
	$(DSIM) \
		$(DSIM_CMP_FLAGS) \
		-f $(CV_CORE_MANIFEST) \
		-work $(DSIM_WORK) \
		-genimage $(DSIM_IMAGE)


# Metrics dsim simulations
.PHONY: dsim-hello-world dsim-firmware

dsim-sanity: dsim-test

dsim-custom:
	@echo "This target is depreciated.  Please use 'make dsim-test TEST=<test-program>'"
	@echo "                             Example:   'make dsim-test TEST=fibonacci'"

dsim-test: dsim-comp $(VERI_CUSTOM)/$(TEST)/$(TEST).hex
	@echo "$(BANNER)"
	@echo "* Running with Metrics DSIM"
	@echo "$(BANNER)"
	mkdir -p $(DSIM_RESULTS)/$(TEST) && cd $(DSIM_RESULTS)/$(TEST)  && \
	$(DSIM) -l dsim-$(TEST).log \
		-image $(DSIM_IMAGE) \
		-work $(DSIM_WORK) \
		$(DSIM_RUN_FLAGS) \
		-sv_lib $(UVM_HOME)/src/dpi/libuvm_dpi.so \
		-sv_lib $(OVP_MODEL_DPI)  \
		+firmware=../../$(VERI_CUSTOM)/$(TEST)/$(TEST).hex

# Metrics dsim cleanup
.PHONY: dsim-clean

dsim-clean: tc-clean
	rm -f dsim.log
	rm -f dsim-*.log
	rm -f metrics_history.db
	rm -f metrics.xml
	rm -f trace_core_00_0.log
	rm -rf dsim_work
	rm -f dsim.env
	rm -f $(DSIM_IMAGE)
	rm -rf $(uIM_RESULTS)

###############################################################################
# Mentor Questasim


.lib-rtl:
	$(VLIB) $(VWORK)
	touch .lib-rtl


.build-rtl: .lib-rtl $(CV_CORE_PKG) $(TBSRC_PKG) $(TBSRC)
	$(VLOG) \
		-work $(VWORK) \
		$(VLOG_FLAGS) \
		-f $(CV_CORE_MANIFEST) \
		$(TBSRC_PKG) $(TBSRC)


vsim-all:  .opt-rtl


.opt-rtl: .build-rtl
	$(VOPT) -work $(VWORK) $(VOPT_FLAGS) $(RTLSRC_VLOG_TB_TOP) -o $(RTLSRC_VOPT_TB_TOP)
	touch .opt-rtl

# run tb and exit
.PHONY: vsim-run
vsim-run: ALL_VSIM_FLAGS += -c
vsim-run: vsim-all
	$(VSIM) -work $(VWORK) $(DPILIB_VSIM_OPT) $(ALL_VSIM_FLAGS)\
	$(RTLSRC_VOPT_TB_TOP) -do 'source $(VSIM_SCRIPT); exit -f'



# run tb and drop into interactive shell
.PHONY: vsim-run-sh
vsim-run-sh: ALL_VSIM_FLAGS += -c
vsim-run-sh: vsim-all
	$(VSIM) -work $(VWORK) $(DPILIB_VSIM_OPT) $(ALL_VSIM_FLAGS) \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

# run tb with simulator gui
.PHONY: vsim-run-gui
vsim-run-gui: ALL_VSIM_FLAGS += $(VSIM_GUI_FLAGS)
vsim-run-gui: vsim-all
	$(VSIM) -work $(VWORK) $(DPILIB_VSIM_OPT) $(ALL_VSIM_FLAGS) \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

.PHONY: questa-custom
questa-custom: vsim-all $(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
questa-custom: ALL_VSIM_FLAGS += +firmware=$(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
questa-custom: vsim-run

.PHONY: questa-custom-gui
questa-custom-gui: vsim-all $(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
questa-custom-gui: ALL_VSIM_FLAGS += +firmware=$(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
questa-custom-gui: vsim-run-gui

.PHONY: questa-cv32_riscv_tests
questa-cv32_riscv_tests: vsim-all $(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
questa-cv32_riscv_tests: ALL_VSIM_FLAGS += +firmware=$(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
questa-cv32_riscv_tests: vsim-run

.PHONY: questa-cv32_riscv_tests-gui
questa-cv32_riscv_tests-gui: vsim-all $(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
questa-cv32_riscv_tests-gui: ALL_VSIM_FLAGS += +firmware=$(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
questa-cv32_riscv_tests-gui: vsim-run-gui

.PHONY: questa-cv32_riscv_compliance_tests
questa-cv32_riscv_compliance_tests: vsim-all $(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
questa-cv32_riscv_compliance_tests: ALL_VSIM_FLAGS += +firmware=$(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
questa-cv32_riscv_compliance_tests: vsim-run

.PHONY: questa-cv32_riscv_compliance_tests-gui
questa-cv32_riscv_compliance_tests-gui: vsim-all $(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
questa-cv32_riscv_compliance_tests-gui: ALL_VSIM_FLAGS += +firmware=$(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
questa-cv32_riscv_compliance_tests-gui: vsim-run-gui

.PHONY: questa-firmware
questa-firmware: vsim-all $(FIRMWARE)/firmware.hex
questa-firmware: ALL_VSIM_FLAGS += +firmware=$(FIRMWARE)/firmware.hex
questa-firmware: vsim-run

.PHONY: questa-firmware-gui
questa-firmware-gui: vsim-all $(FIRMWARE)/firmware.hex
questa-firmware-gui: ALL_VSIM_FLAGS += +firmware=$(FIRMWARE)/firmware.hex
questa-firmware-gui: vsim-run-gui

.PHONY: questa-unit-test
questa-unit-test:  firmware-unit-test-clean
questa-unit-test:  $(FIRMWARE)/firmware_unit_test.hex
questa-unit-test: ALL_VSIM_FLAGS += "+firmware=$(FIRMWARE)/firmware_unit_test.hex"
questa-unit-test: vsim-run

.PHONY: questa-unit-test-gui
questa-unit-test-gui:  firmware-unit-test-clean
questa-unit-test-gui:  $(FIRMWARE)/firmware_unit_test.hex
questa-unit-test-gui: ALL_VSIM_FLAGS += "+firmware=$(FIRMWARE)/firmware_unit_test.hex"
questa-unit-test-gui: vsim-run-gui

questa-clean:
	if [ -d $(VWORK) ]; then rm -r $(VWORK); fi
	rm -f transcript vsim.wlf vsim.dbg trace_core*.log \
	.build-rtl .opt-rtl .lib-rtl *.vcd objdump

###############################################################################
# Cadence Xcelium xrun testbench compilation
.PHONY: xrun-all
xrun-all: $(CV_CORE_PKG) $(RTLSRC_PKG) $(RTLSRC) $(TBSRC_PKG) $(TBSRC)
	$(XRUN) \
		$(XRUN_FLAGS) \
		-f $(CV_CORE_MANIFEST) \
		$(TBSRC_PKG) $(TBSRC)

xrun-custom:
	@echo "This target is depreciated.  Please use 'make xrun-test TEST=<test-program>'"
	@echo "                             Example:   'make xrun-test TEST=fibonacci'"

.PHONY: xrun-test
xrun-test: xrun-all $(VERI_CUSTOM)/$(TEST)/$(TEST).hex
	$(XRUN) \
		$(XRUN_FLAGS) \
		-f $(CV_CORE_MANIFEST) \
		$(TBSRC_PKG) $(TBSRC) \
		+firmware=$(VERI_CUSTOM)/$(TEST)/$(CUSTOM_PROG).hex

# Cadence Xcelium xrun cleanup
.PHONY: xrun-clean xrun-clean-all
xrun-clean:
	rm -vrf $(XRUN_DIR)
	if [ -e xrun.history ]; then rm xrun.history; fi
	if [ -e xrun.log ]; then rm xrun.log; fi

xrun-clean-all: xrun-clean
	rm -vrf $(addprefix $(FIRMWARE)/firmware., elf bin hex map) \
		$(FIRMWARE_OBJS) $(FIRMWARE_TEST_OBJS) $(COMPLIANCE_TEST_OBJS)

###############################################################################
# Verilator

# Verilator wave support is handled in the DSIM WAVES block above (FST format)

SIM_RESULTS          = simulation_results
SIM_TEST_RESULTS     = $(SIM_RESULTS)/$(TEST)

verilate: CV_CORE_pkg $(TBSRC_VERI) $(TBSRC_PKG)
	@echo "$(BANNER)"
	@echo "* Compiling CORE TB and CV32E40S with Verilator"
	@echo "$(BANNER)"
	$(VERILATOR) --binary --cc --sv --exe \
		$(VERI_TRACE) \
		--top-module tb_top \
		$(TBSRC_VERI) \
		-f $(CV_CORE_MANIFEST) \
		--Mdir $(VERI_OBJ_DIR) \
		-CFLAGS "-std=gnu++14 $(VERI_CFLAGS)" \
		$(VERI_COMPILE_FLAGS)
	mkdir -p $(SIM_RESULTS)
	mkdir -p $(SIM_TEST_RESULTS)
	mv $(VERI_OBJ_DIR)/Vtb_top $(SIM_TEST_RESULTS)/verilator_executable

sanity-veri-run:
	make verilate TEST=hello-world

veri-test: verilate $(VERI_CUSTOM)/$(TEST)/$(TEST).hex
	@echo "$(BANNER)"
	@echo "* Running with Verilator: logfile in $(VERI_LOG_DIR)/$(TEST).log"
	@echo "$(BANNER)"
	mkdir -p $(VERI_LOG_DIR)
	$(SIM_TEST_RESULTS)/verilator_executable $(VERI_FLAGS) \
		"+test_program=$(VERI_CUSTOM)/$(TEST)/$(TEST).hex" \
		| tee $(VERI_LOG_DIR)/$(TEST).log

# verilator specific cleanup
veri-clean: verilate-clean

verilate-clean: tc-clean
	if [ -d $(VERI_LOG_DIR) ]; then rm -r $(VERI_LOG_DIR); fi
	if [ -d $(VERI_OBJ_DIR) ]; then rm -r $(VERI_OBJ_DIR); fi
	if [ -d $(SIM_RESULTS) ]; then rm -r $(SIM_RESULTS); fi
	rm -rf testbench_verilator
	if [ -e memory_dump.bin ]; then rm memory_dump.bin; fi


###############################################################################
# Synopsys VCS

vcsify: CV_CORE_pkg tbsrc_pkg tbsrc
	$(VCS) +vc -sverilog -race=all -ignore unique_checks -full64 \
		-timescale=1ns/1ps \
		-assert svaext \
		-CC "-I$(VCS_HOME)/include -O3 -march=native" $(VCS_FLAGS) \
		-f $(MAKE_DIR)/$(CV_CORE_MANIFEST) \
		$(TBSRC_PKG) $(TBSRC)

RTLSRC_TB_TOP	:= $(basename $(notdir $(TBSRC_TOP)))

vcs-run: vcsify
	$(SIMV) $(ALL_VCS_FLAGS) -ucli -do $(VCS_SCRIPT)

vcs-run-gui: vcsify
	$(SIMV) $(ALL_VCS_FLAGS) -gui -do $(VCS_SCRIPT_GUI)

.PHONY: vcs-hello-world
vcs-hello-world: vcsify $(CUSTOM)/hello-world.hex
vcs-hello-world: ALL_VCS_FLAGS += +firmware=$(CUSTOM)/hello-world.hex
vcs-hello-world: vcs-run

.PHONY: vcs-custom
vcs-custom: vcsify $(CUSTOM)/$(CUSTOM_PROG).hex
vcs-custom: ALL_VCS_FLAGS += +firmware=$(CUSTOM)/$(CUSTOM_PROG).hex
vcs-custom: vcs-run

.PHONY: vcs-cv32_riscv_tests
vcs-cv32_riscv_tests: vcsify $(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
vcs-cv32_riscv_tests: ALL_VCS_FLAGS += +firmware=$(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
vcs-cv32_riscv_tests: vcs-run

.PHONY: vcs-cv32_riscv_tests-gui
vcs-cv32_riscv_tests-gui: vcsify $(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
vcs-cv32_riscv_tests-gui: ALL_VCS_FLAGS += +firmware=$(CV32_RISCV_TESTS_FIRMWARE)/cv32_riscv_tests_firmware.hex
vcs-cv32_riscv_tests-gui: vcs-run-gui

.PHONY: vcs-cv32_riscv_compliance_tests
vcs-cv32_riscv_compliance_tests: vcsify $(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
vcs-cv32_riscv_compliance_tests: ALL_VCS_FLAGS += +firmware=$(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
vcs-cv32_riscv_compliance_tests: vcs-run

.PHONY: vcs-cv32_riscv_compliance_tests-gui
vcs-cv32_riscv_compliance_tests-gui: vcsify $(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
vcs-cv32_riscv_compliance_tests-gui: ALL_VCS_FLAGS += +firmware=$(CV32_RISCV_COMPLIANCE_TESTS_FIRMWARE)/cv32_riscv_compliance_tests_firmware.hex
vcs-cv32_riscv_compliance_tests-gui: vcs-run-gui

.PHONY: vcs-firmware
vcs-firmware: vcsify $(FIRMWARE)/firmware.hex
vcs-firmware: ALL_VCS_FLAGS += +firmware=$(FIRMWARE)/firmware.hex
vcs-firmware: vcs-run

.PHONY: vcs-firmware-gui
vcs-firmware-gui: vcsify $(FIRMWARE)/firmware.hex
vcs-firmware-gui: ALL_VCS_FLAGS += +firmware=$(FIRMWARE)/firmware.hex
vcs-firmware-gui: vcs-run-gui

.PHONY: vcs-unit-test
vcs-unit-test:  firmware-unit-test-clean
vcs-unit-test:  $(FIRMWARE)/firmware_unit_test.hex
vcs-unit-test: ALL_VCS_FLAGS += "+firmware=$(FIRMWARE)/firmware_unit_test.hex"
vcs-unit-test: vcs-run

.PHONY: vcs-unit-test-gui
vcs-unit-test-gui:  firmware-unit-test-clean
vcs-unit-test-gui:  $(FIRMWARE)/firmware_unit_test.hex
vcs-unit-test-gui: ALL_VCS_FLAGS += "+firmware=$(FIRMWARE)/firmware_unit_test.hex"
vcs-unit-test-gui: vcs-run-gui

vcs-clean:
	rm -rf simv* *.daidir *.vpd *.db csrc ucli.key vc_hdrs.h

###############################################################################
# Aldec Riviera-PRO

.rvrlib-rtl:
	$(ALIB) $(AWORK)
	touch .rvrlib-rtl

rvr-build-rtl: .rvrlib-rtl CV_CORE_pkg tbsrc_pkg tbsrc
	$(ALOG) \
		-work $(AWORK) \
		$(ALOG_FLAGS) \
		$(ALOG_UVM) \
		-f $(CV_CORE_MANIFEST) \
		$(TBSRC_PKG) $(TBSRC)

asim-all:  .rvr-build-rtl

# run tb and exit
.PHONY: asim-run
asim-run: ALL_ASIM_FLAGS += -c
asim-run: rvr-build-rtl
	$(ASIM) -lib $(AWORK) $(ALL_ASIM_FLAGS)\
	$(RTLSRC_VLOG_TB_TOP) -do "run -all; endsim; quit -force"

# run tb and drop into interactive shell
.PHONY: asim-run-sh
asim-run-sh: ALL_ASIM_FLAGS += -c
asim-run-sh: rvr-build-rtl
	$(ASIM) -lib $(AWORK) $(ALL_ASIM_FLAGS) \
	$(RTLSRC_VLOG_TB_TOP) -do "run -all"

# run tb with simulator gui
.PHONY: asim-run-gui
asim-run-gui: ALL_ASIM_FLAGS += $(ASIM_GUI_FLAGS)
asim-run-gui: rvr-build-rtl
	$(ASIM) -lib $(AWORK) $(ALL_ASIM_FLAGS) \
	$(RTLSRC_VLOG_TB_TOP) -do "run -all"

.PHONY: riviera-hello-world
riviera-hello-world: rvr-build-rtl $(CUSTOM)/hello-world/hello-world.hex
riviera-hello-world: ALL_ASIM_FLAGS += +firmware=$(CUSTOM)/hello-world/hello-world.hex
riviera-hello-world: asim-run

.PHONY: riviera-hello-world-gui
riviera-hello-world-gui: rvr-build-rtl $(CUSTOM)/hello-world/hello-world.hex
riviera-hello-world-gui: ALL_ASIM_FLAGS += +firmware=$(CUSTOM)/hello-world/hello-world.hex
riviera-hello-world-gui: asim-run-gui

.PHONY: riviera-custom
riviera-custom: rvr-build-rtl $(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
riviera-custom: ALL_ASIM_FLAGS += +firmware=$(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
riviera-custom: asim-run

.PHONY: riviera-custom-gui
riviera-custom-gui: rvr-build-rtl $(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
riviera-custom-gui: ALL_ASIM_FLAGS += +firmware=$(CUSTOM)/$(CUSTOM_PROG)/$(CUSTOM_PROG).hex
riviera-custom-gui: asim-run-gui

riviera-clean:
	if [ -d $(AWORK) ]; then rm -r $(AWORK); fi
	rm -f transcript trace_core*.log \
	.build-rtl .rvrlib-rtl *.vcd objdump *.asdb *.cfg dpi_header.h

###############################################################################
# CV_CORE RTL dependencies

clone_$(CV_CORE_LC)_rtl clone_rtl:
	@echo "$(BANNER)"
	@echo "* Cloning CV32E40S RTL model"
	@echo "$(BANNER)"
	$(CLONE_CV_CORE_CMD)




###############################################################################
# general targets
.PHONY: tc-clean

# clean up toolchain generated files
clean-test-programs:
	find $(CV32E40S_DV)/tests/programs -name "*.o"       -exec rm {} \;
	find $(CV32E40S_DV)/tests/programs -name "*.hex"     -exec rm {} \;
	find $(CV32E40S_DV)/tests/programs -name "*.elf"     -exec rm {} \;
	find $(CV32E40S_DV)/tests/programs -name "*.map"     -exec rm {} \;
	find $(CV32E40S_DV)/tests/programs -name "*.readelf" -exec rm {} \;
	find $(CV32E40S_DV)/tests/programs -name "*.objdump" -exec rm {} \;

.PHONY: clean clean_all distclean
clean: clean-test-programs questa-clean verilate-clean vcs-clean firmware-clean dsim-clean xrun-clean vcs-clean clean_bsp riviera-clean

distclean: clean
	rm -rf riscv-fesvr riscv-isa-sim $(CV_CORE_PKG) work

clean_all: distclean
#endend

###############################################################################
# ACT4 Certification workflow
###############################################################################

# config selector (override on command line for future variants, e.g. rv32imcb)
CV_CORE_CONFIG   ?= rv32imc_PMA-PMP
CERT_CONFIG_NAME  = cv32e40s_$(CV_CORE_CONFIG)

###############################################################################
# Certification profile: scopes which extension testplans ACT4 processes.
# ACT4's select_tests() further filters by the core's implemented_extensions.
# Without CERT_PROFILE, ACT4 runs the full config (no EXTENSIONS= filter).
# Supported profiles: rvi20
CERT_PROFILE ?=

ifeq ($(CERT_PROFILE),rvi20)
  # RVI20U32 profile — mandatory: I; optional: A,C,D,F,M,Zca,Zcd,Zcf,Zicntr,Zicsr,Zifencei,Zihpm
  _CERT_EXTS = I,M,A,C,D,F,Zca,Zcd,Zcf,Zicntr,Zicsr,Zifencei,Zihpm
else ifneq ($(CERT_PROFILE),)
  $(error Unknown CERT_PROFILE=$(CERT_PROFILE). Supported: rvi20)
endif

###############################################################################
# certification test-program directories
certification_PROGRAM_PATH    = $(ACT4_PKG)/work/$(CERT_CONFIG_NAME)/elfs
certification_PROGRAM_RELPATH = ../../vendor_lib/riscv-arch-test/act4/work/$(CERT_CONFIG_NAME)/elfs
CERT_RESULTS_DIR = certification$(if $(CERT_PROFILE),_$(CERT_PROFILE))

###############################################################################
# certification test target (run ALL ELFs under compliance/rv32, quiet + summary)
.PHONY: gen
gen: $(ACT4_PKG)
	@command -v uv >/dev/null 2>&1 || { echo "Error: 'uv' not found. Install from https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }
	@$(MAKE) -C $(ACT4_PKG) clean
	@echo "* Running ACT4.0 gen$(if $(CERT_PROFILE), with profile '$(CERT_PROFILE)' extensions: $(_CERT_EXTS))"
	@$(MAKE) -C $(ACT4_PKG) \
	    $(if $(_CERT_EXTS),EXTENSIONS=$(_CERT_EXTS)) \
	    CONFIG_FILES=config/cores/cv32e40s/$(CERT_CONFIG_NAME)/test_config.yaml

.PHONY: certify
certify: TEST = $(CERT_RESULTS_DIR)
certify: verilate
	@echo "$(BANNER)"
	@echo "* Running ALL compliance ELFs with Verilator"
	@echo "$(BANNER)"
	@set -e; \
	mkdir -p "$(VERI_LOG_DIR)"; \
	SUMMARY="$(VERI_LOG_DIR)/certification_summary.txt"; \
	echo "RESULT  TEST" > "$$SUMMARY"; \
	echo "------  ----" >> "$$SUMMARY"; \
	ROOT="$(certification_PROGRAM_PATH)/rv32i"; \
	ELFS="$$(find -L "$$ROOT" \( -type f -o -type l \) -a \( -iname '*.elf' -o -iname '*.elf32' \) 2>/dev/null | sort)"; \
	if [ -z "$$ELFS" ]; then \
	  echo "No .elf files found under $$ROOT"; \
	  echo "Debug listing (2 levels):"; \
	  find "$$ROOT" -maxdepth 2 -print || true; \
	  exit 2; \
	fi; \
	PASS=0; FAIL=0; TOTAL=0; \
	for ELF in $$ELFS; do \
	  TOTAL=$$((TOTAL+1)); \
	  REL="$${ELF#$$ROOT/}"; \
	  BASE="$${ELF%.*}"; \
	  HEX="$$BASE.hex"; \
	  LOG="$(VERI_LOG_DIR)/$${REL%.*}.log"; \
	  mkdir -p "$$(dirname "$$LOG")"; \
	  if [ ! -f "$$HEX" ] || [ "$$ELF" -nt "$$HEX" ]; then \
	    riscv64-unknown-elf-objcopy -O verilog "$$ELF" "$$HEX"; \
	  fi; \
	  ENTRY=$$(riscv64-unknown-elf-readelf -h "$$ELF" | awk '/Entry point/{print $$NF}'); \
	  set +e; \
	  "$(SIM_TEST_RESULTS)/verilator_executable" \
	    $(VERI_RUN_FLAGS) \
	    $(VERI_WAVE_CMD) \
	    "+test_program=$$HEX" \
	    "+boot_addr=$$ENTRY" \
	    > "$$LOG" 2>&1; \
	  RC=$$?; \
	  set -e; \
	  if [ $$RC -eq 0 ] && grep -q "ALL TESTS PASSED" "$$LOG"; then \
	    echo "PASS    $$REL" | tee -a "$$SUMMARY"; \
	    PASS=$$((PASS+1)); \
	  else \
	    echo "FAIL    $$REL" | tee -a "$$SUMMARY"; \
	    FAIL=$$((FAIL+1)); \
	  fi; \
	done; \
	echo "" | tee -a "$$SUMMARY"; \
	echo "TOTAL=$$TOTAL PASS=$$PASS FAIL=$$FAIL" | tee -a "$$SUMMARY"; \
	echo "Summary saved to: $$SUMMARY"; \
	true

.PHONY: gen-certify
gen-certify: gen certify

###############################################################################
# Questa (vsim) certification flow
# Usage:
#   make questa-compile [CV_CORE_CONFIG=rv32imc]  # compile once
#   make certify-vsim   [CV_CORE_CONFIG=rv32imc]  # run all ELFs under rv32i/
#   make certify-vsim FILTER=I                     # run only rv32i/I ELFs
#   make gen-certify-vsim [CV_CORE_CONFIG=rv32imc] # gen + compile + run
#   make questa-clean   [CV_CORE_CONFIG=rv32imc]   # wipe work library
###############################################################################

CERT_VSIM_WORK_DIR = $(SIM_RESULTS)/questa_$(CV_CORE_CONFIG)
CERT_VSIM_LOG_DIR  = $(CERT_VSIM_WORK_DIR)/logs
CERT_VSIM_OPT_TOP  = tb_top_opt

# NOTE: with a full Questa license, remove +define+VERILATOR below and add a
# separate vlog step for tb_riscv/riscv_random_interrupt_generator.sv (after
# TBSRC_PKG, before TBSRC_VERI) — mm_ram.sv instantiates it under `ifndef VERILATOR.
# With Questa FSE (Altera Starter), keep +define+VERILATOR.
CERT_VLOG_FLAGS = -sv -work $(CERT_VSIM_WORK_DIR) \
                  +define+VERILATOR \
                  -suppress 2583
CERT_VOPT_FLAGS = -work $(CERT_VSIM_WORK_DIR) \
                  +acc -o $(CERT_VSIM_OPT_TOP)
CERT_VSIM_MAX_CYCLES ?= 2000000
CERT_VSIM_FLAGS = -work $(CERT_VSIM_WORK_DIR) \
                  -batch -quiet \
                  -sv_seed 0 \
                  +nowarnTSCALE \
                  -suppress 8386 \
                  -suppress 3009 \
                  -do "run -all; quit -f" \
                  +maxcycles=$(CERT_VSIM_MAX_CYCLES)

.PHONY: questa-compile
questa-compile: CV_CORE_pkg
	@echo "$(BANNER)"
	@echo "* Compiling CORE TB and CV32E40S with Questa (CV_CORE_CONFIG=$(CV_CORE_CONFIG))"
	@echo "$(BANNER)"
	mkdir -p $(CERT_VSIM_WORK_DIR)
	$(VLOG) $(CERT_VLOG_FLAGS) -f $(CV_CORE_MANIFEST)
	$(VLOG) $(CERT_VLOG_FLAGS) $(TBSRC_PKG)
	$(VLOG) $(CERT_VLOG_FLAGS) $(TBSRC_VERI)
	$(VOPT) $(CERT_VOPT_FLAGS) tb_top

.PHONY: certify-vsim
certify-vsim: TEST = $(CERT_RESULTS_DIR)
certify-vsim:
	@test -d "$(CERT_VSIM_WORK_DIR)/$(CERT_VSIM_OPT_TOP)" || { echo "Error: optimized design '$(CERT_VSIM_OPT_TOP)' not found. Run 'make questa-compile' first."; exit 1; }
	@echo "$(BANNER)"
	@echo "* Running ALL compliance ELFs with Questa (CV_CORE_CONFIG=$(CV_CORE_CONFIG))"
	@echo "$(BANNER)"
	@set -e; \
	mkdir -p "$(CERT_VSIM_LOG_DIR)"; \
	SUMMARY="$(CERT_VSIM_LOG_DIR)/certification_summary.txt"; \
	echo "RESULT  TEST" > "$$SUMMARY"; \
	echo "------  ----" >> "$$SUMMARY"; \
	ROOT="$(certification_PROGRAM_PATH)/rv32i$(if $(FILTER),/$(FILTER),)"; \
	ELFS="$$(find -L "$$ROOT" \( -type f -o -type l \) -a \( -iname '*.elf' -o -iname '*.elf32' \) 2>/dev/null | sort)"; \
	if [ -z "$$ELFS" ]; then \
	  echo "No .elf files found under $$ROOT"; \
	  echo "Debug listing (2 levels):"; \
	  find "$$ROOT" -maxdepth 2 -print || true; \
	  exit 2; \
	fi; \
	PASS=0; FAIL=0; TOTAL=0; \
	while IFS= read -r ELF; do \
	  TOTAL=$$((TOTAL+1)); \
	  REL="$${ELF#$$ROOT/}"; \
	  BASE="$${ELF%.*}"; \
	  HEX="$$BASE.hex"; \
	  LOG="$(CERT_VSIM_LOG_DIR)/$${REL%.*}.log"; \
	  mkdir -p "$$(dirname "$$LOG")"; \
	  if [ ! -f "$$HEX" ] || [ "$$ELF" -nt "$$HEX" ]; then \
	    riscv64-unknown-elf-objcopy -O verilog "$$ELF" "$$HEX"; \
	  fi; \
	  ENTRY=$$(riscv64-unknown-elf-readelf -h "$$ELF" | awk '/Entry point/{print $$NF}'); \
	  ENTRY_HEX=$${ENTRY#0x}; \
	  set +e; \
	  $(VSIM) $(CERT_VSIM_FLAGS) \
	    $(CERT_VSIM_OPT_TOP) \
	    "+test_program=$$HEX" \
	    "+boot_addr=$$ENTRY_HEX" \
	    > "$$LOG" 2>&1; \
	  RC=$$?; \
	  set -e; \
	  if [ $$RC -eq 0 ] && grep -q "ALL TESTS PASSED" "$$LOG"; then \
	    echo "PASS    $$REL" | tee -a "$$SUMMARY"; \
	    PASS=$$((PASS+1)); \
	  else \
	    echo "FAIL    $$REL" | tee -a "$$SUMMARY"; \
	    FAIL=$$((FAIL+1)); \
	  fi; \
	done <<< "$$ELFS"; \
	echo "" | tee -a "$$SUMMARY"; \
	echo "TOTAL=$$TOTAL PASS=$$PASS FAIL=$$FAIL" | tee -a "$$SUMMARY"; \
	echo "Summary saved to: $$SUMMARY"; \
	true

.PHONY: gen-certify-vsim
gen-certify-vsim: gen questa-compile certify-vsim

.PHONY: questa-clean
questa-clean:
	rm -rf $(CERT_VSIM_WORK_DIR)
