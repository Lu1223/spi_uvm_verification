# SPI Master UVM 验证

SPI Master DUT 的完整 UVM 验证平台：寄存器抽象层（RAL）+ 参考模型计分板 + 功能覆盖率闭环。**4 个测试全 PASS（0 UVM_ERROR），代码覆盖率 92.76%，功能覆盖率 100%**。附带教学版骨架工程（手搭 UVM 环境练习用）。

## DUT 功能

`v1_full/rtl/spi_master.sv` —— SPI 主机 + 简易同步寄存器总线：

- **SPI 主机**：支持 CPOL/CPHA 四种工作模式、可配置分频（sclk 半周期 = clk_div 个系统时钟）、8bit 字节传输
- **寄存器总线**（单周期无等待，bus_ready 恒等于 bus_valid）：

| 偏移 | 寄存器 | 说明 |
|---|---|---|
| 0x00 | CTRL | [0] spi_en [1] cpol [2] cpha |
| 0x04 | DIVIDER | [7:0] clk_div（写入 <2 按 2 处理） |
| 0x08 | TX_DATA | 写该寄存器启动一次 8bit 传输（仅 spi_en=1 且 busy=0 时有效） |
| 0x0C | RX_DATA | 只读，最近一次传输收到的字节 |
| 0x10 | STATUS | [0] busy [1] rx_valid（新传输启动时清零） |

传输 FSM：IDLE → TRANSFER（16 个半周期）→ IDLE。CPHA=0 前沿采样/后沿移位，CPHA=1 前沿移位/后沿采样。

## 验证环境架构

```
spi_tb_top（顶层：clk/rst + DUT + spi_if + reg_if 连接 + run_test）
└── spi_env
    ├── spi_reg_agent（寄存器侧）
    │   ├── spi_reg_driver      —— 驱动简易同步总线
    │   ├── spi_reg_monitor     —— 采样总线事务
    │   ├── spi_reg_adapter     —— uvm_reg_bus_op ↔ reg_item 转换
    │   ├── spi_reg_raw_seq     —— 寄存器原始序列
    │   └── predictor           —— 事务级更新 RAL 镜像值
    ├── spi_reg_block（RAL 寄存器模型）—— CTRL/DIVIDER/TX_DATA/RX_DATA/STATUS
    ├── spi_slave_driver       —— SPI 从机行为模型（可配置回送数据，四模式对齐）
    ├── spi_bus_monitor        —— SPI 引脚级采样 → 字节级事务
    ├── spi_cov_collector      —— 4 个 covergroup 功能覆盖率收集
    └── spi_scoreboard         —— 计分板（期望值由 test 推入 → 实际比对）
```

## 测试用例（4 个全 PASS）

| 测试 | 场景 | 覆盖点 |
|---|---|---|
| spi_smoke_test | 冒烟：复位值检查 + 单次传输闭环 | 最小通路 |
| spi_mode_test | CPOL/CPHA 四模式 × 3 组典型数据 | 模式组合 |
| spi_rand_test | 随机模式/分频/数据/次数回归 | 随机约束 |
| spi_corner_test | 极值分频、边界数据(00/FF)、en=0 拒写、busy 时写忽略、rx_valid 清零 | 边界异常 |

## 覆盖率闭环（v1_full）

初跑代码覆盖率 84.98% → URG 报告分析缺口 → 补充 corner 用例与 covergroup → 最终：

| 指标 | 结果 |
|---|---|
| SCORE | **92.76%** |
| LINE | 98.51% |
| COND | 98.04% |
| BRANCH | 97.06% |
| TOGGLE | 77.42% |
| 功能覆盖率 | **100%**（4 个 covergroup：寄存器访问 / 模式-数据组合 / 传输时序 / 状态转换） |

## 双版本说明

| 目录 | 内容 | 用途 |
|---|---|---|
| `v1_full/` | DUT + 完整 UVM 环境（20 个文件）+ 构建脚本 | 直接跑通看结果 |
| `v2_tutorial/` | DUT 完整 + UVM 环境**骨架文件**（待补全）+ `solution/` 参考答案 | 手搭环境练习：对照 v1_full 逐文件补全，卡住看 solution |

## 快速开始

工具链：VCS 2023.12-SP2 + Verdi（RHEL 8.10 虚拟机，license server 27000@localhost.localdomain）。

### Windows 一键

双击 `v1_full/sim/run_vcs.bat` —— SSH 到 VM 自动完成：连通检查 → 编译 → 4 测试 → 日志回传 → PASS/FAIL 汇总。

### VM 手动

```bash
cd ~/eda_sim/spi_uvm_sim            # 工作区（源码经 hgfs 共享自 Windows）
make compile && make run_all        # 编译 + 4 测试汇总
make cov                            # urg 覆盖率报告（HTML+文本）
./verdi_run.sh                      # Verdi 波形（图形终端）
```

Makefile 中源码路径（`SRC := /mnt/hgfs/...`）按实际共享目录调整。

## 目录结构

```
spi_uvm_verification/
├── v1_full/                # 完整工程
│   ├── rtl/spi_master.sv             # DUT
│   ├── tb/                           # UVM 环境（20 个文件）
│   └── sim/                          # Makefile / filelist.f / run_all.sh
│                                     # verdi_run.sh / run_vcs.bat
└── v2_tutorial/            # 教学版
    ├── rtl/spi_master.sv             # DUT（完整给出）
    ├── tb/                           # UVM 环境骨架（待补全，共 21 个文件）
    ├── solution/                     # 参考答案（已跑通验证）
    └── sim/                          # Makefile / filelist*.f / verdi_run.sh
```

## 技术要点

- **RAL 镜像一致性**：reg block `configure()` 后必须显式 `build()`；predictor 异步更新镜像，读后比对需留时序窗口
- **SPI 边沿对齐**：CPHA=1 时 slave 模型与 monitor 需跳过一个移位沿（采样沿 = CPOL==CPHA ? 上升沿 : 下降沿）
- **计分板期望值注入**：test 层通过 `push_exp()` 推入期望（被 DUT 忽略的写不推入），实现写-读-回环逐笔比对
- **假 PASS 防护**：run_all.sh 判定同时检查日志存在、UVM_ERROR/FATAL 计数、VCS Error 标记三重条件
