# ============================================================================
# Makefile —— SPI UVM 验证 VCS 一键流程（VM 本地工作区版）
# 工作目录：/home/yian/eda_sim/spi_uvm_sim（VM 本地）
# 源码目录：/mnt/hgfs/Code_total/SPI_IC/v1_full（Windows 共享）
#
# 用法：
#   make compile                 只编译（含代码+断言覆盖率采集选项）
#   make run TEST=spi_smoke_test 运行指定测试
#   make all  TEST=xxx           编译 + 运行
#   make run_all                 依次跑全部 4 个测试并汇总
#   make cov                     生成 urg 覆盖率报告（HTML+文本，需先 make run）
#   make wave                    用 Verdi 打开波形（需先 make run）
#   make sync_logs               把 log/报告回传到 Windows 共享目录
#   make clean                   清理
# ============================================================================

# ---- 环境变量（非交互 shell 不读 .bashrc，这里显式导出）----
export SNPSLMD_LICENSE_FILE := 27000@localhost.localdomain
export LM_LICENSE_FILE := $(SNPSLMD_LICENSE_FILE)
export VCS_HOME := /home/yian/Synopsys/vcs/V-2023.12-SP2
export VERDI_HOME := /home/yian/Synopsys/verdi/V-2023.12-SP2
export LD_LIBRARY_PATH := $(VERDI_HOME)/share/PLI/VCS/linux64

VCS  := $(VCS_HOME)/bin/vcs -full64
PLI  := $(VERDI_HOME)/share/PLI/VCS/linux64
SRC  := /mnt/hgfs/Code_total/SPI_IC/v1_full
SYNC := $(SRC)/sim

TEST ?= spi_smoke_test
SEED ?= 1
VERB ?= UVM_MEDIUM

# ------------------- 编译 -------------------
# -timescale=1ns/1ps：全局时间单位（UVM 库文件无 timescale）
# -cm line+cond+fsm+tgl+branch+assert：代码覆盖率 + 断言覆盖率采集
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

# ------------------- 运行单个测试 -------------------
run:
	./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) \
	  +ntb_random_seed=$(SEED) \
	  -cm line+cond+fsm+tgl+branch+assert -cm_name $(TEST) \
	  -l run_$(TEST).log

# ------------------- 全部 4 个测试 -------------------
run_all:
	./run_all.sh

# ------------------- 一键编译+运行 -------------------
all: compile run

# ------------------- 覆盖率报告（urg 生成 HTML + 文本） -------------------
cov:
	PATH=$(VCS_HOME)/bin:$$PATH urg -dir simv.vdb -report both

# ------------------- Verdi 波形 -------------------
wave:
	./verdi_run.sh

# ------------------- 把 log/报告回传到 Windows 共享目录 -------------------
sync_logs:
	cp -f run_*.log compile.log $(SYNC)/ 2>/dev/null || true
	cp -rf urgReport $(SYNC)/ 2>/dev/null || true

# ------------------- 清理 -------------------
clean:
	rm -rf simv simv.daidir csrc *.log *.fsdb novas.* ucli.key inter.vpd DVEfiles *.vpd simv.vdb urgReport
