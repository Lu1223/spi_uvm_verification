# ============================================================================
# Makefile —— SPI 教学版 VCS 流程（VM 本地工作区版）
# 工作目录：/home/yian/eda_sim/spi_uvm_sim_v2（VM 本地）
# 源码目录：/mnt/hgfs/Code_total/SPI_IC/v2_tutorial（Windows 共享）
#
# 用法：
#   make compile                 编译"你自己写的"tb/ 版本
#   make run TEST=spi_smoke_test 运行你自己的版本
#   make compile_solution        编译参考答案（solution/，跑通后对比用）
#   make run_solution            运行参考答案
#   make wave                    用 Verdi 打开波形（需先 make run）
#   make sync_logs               把 log 回传到 Windows 共享目录
#   make clean                   清理
# ============================================================================

export SNPSLMD_LICENSE_FILE := 27000@localhost.localdomain
export LM_LICENSE_FILE := $(SNPSLMD_LICENSE_FILE)
export VCS_HOME := /home/yian/Synopsys/vcs/V-2023.12-SP2
export VERDI_HOME := /home/yian/Synopsys/verdi/V-2023.12-SP2
export LD_LIBRARY_PATH := $(VERDI_HOME)/share/PLI/VCS/linux64

VCS  := $(VCS_HOME)/bin/vcs -full64
PLI  := $(VERDI_HOME)/share/PLI/VCS/linux64
SRC  := /mnt/hgfs/Code_total/SPI_IC/v2_tutorial
SYNC := $(SRC)/sim

TEST ?= spi_smoke_test
SEED ?= 1
VERB ?= UVM_MEDIUM

# ------------------- 编译：你自己的版本 -------------------
compile:
	$(VCS) -sverilog -timescale=1ns/1ps \
	  -ntb_opts uvm-1.2 \
	  -debug_access+all \
	  -lca -kdb \
	  -cm line+cond+fsm+tgl+branch+assert \
	  -P $(PLI)/novas.tab $(PLI)/pli.a \
	  +incdir+$(SRC)/tb \
	  -f filelist.f \
	  -top spi_tb_top \
	  -o simv \
	  -l compile.log

# ------------------- 编译：参考答案 -------------------
compile_solution:
	$(VCS) -sverilog -timescale=1ns/1ps \
	  -ntb_opts uvm-1.2 \
	  -debug_access+all \
	  -lca -kdb \
	  -cm line+cond+fsm+tgl+branch+assert \
	  -P $(PLI)/novas.tab $(PLI)/pli.a \
	  +incdir+$(SRC)/solution \
	  -f filelist_solution.f \
	  -top spi_tb_top \
	  -o simv_sol \
	  -l compile_solution.log

# ------------------- 运行单个测试 -------------------
run:
	./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) \
	  +ntb_random_seed=$(SEED) \
	  -cm line+cond+fsm+tgl+branch+assert -cm_name $(TEST) \
	  -l run_$(TEST).log

run_solution:
	./simv_sol +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) \
	  +ntb_random_seed=$(SEED) \
	  -cm line+cond+fsm+tgl+branch+assert -cm_name $(TEST)_sol \
	  -l run_$(TEST)_sol.log

# ------------------- Verdi 波形 -------------------
wave:
	./verdi_run.sh

# ------------------- 把 log 回传到 Windows 共享目录 -------------------
sync_logs:
	cp -f run_*.log compile*.log $(SYNC)/ 2>/dev/null || true

# ------------------- 清理 -------------------
clean:
	rm -rf simv simv_sol simv.daidir csrc *.log *.fsdb novas.* ucli.key inter.vpd DVEfiles *.vpd simv.vdb urgReport
