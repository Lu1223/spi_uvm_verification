#!/bin/bash
# ============================================================================
# verdi_run.sh —— 用 Verdi 打开仿真波形与源码
#   前提：已执行 make run（生成了 simv.fsdb 波形和 simv.daidir 源码库）
#   用法：在 VM 图形终端里执行 ./verdi_run.sh
# ============================================================================
VERDI_HOME=/home/yian/Synopsys/verdi/V-2023.12-SP2
export SNPSLMD_LICENSE_FILE=27000@localhost.localdomain

# -dbdir : 加载 VCS -kdb 生成的知识库（源码浏览/信号驱动追踪）
# -ssf   : 加载 FSDB 波形文件
$VERDI_HOME/bin/verdi -dbdir ./simv.daidir -ssf simv.fsdb -nologo &
