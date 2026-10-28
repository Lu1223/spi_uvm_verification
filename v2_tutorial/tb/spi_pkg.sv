// ============================================================================
// spi_pkg.sv —— 验证包（骨架文件）
// 【对应指导文档】docs/03~11 各步都会往这里加 include
// 【你要写的】import + include 列表（按依赖顺序）+ sequencer typedef
// ============================================================================
package spi_pkg;

  // TODO 1：import uvm_pkg::*;  +  `include "uvm_macros.svh"

  // TODO 2：声明 analysis imp 宏（scoreboard/cov 多输入口要用）：
  //   `uvm_analysis_imp_decl(_reg)   —— 收 spi_reg_item
  //   `uvm_analysis_imp_decl(_spi)   —— 收 spi_bus_trans
  //   `uvm_analysis_imp_decl(_slave) —— 收 spi_slave_item

  // TODO 3：按依赖顺序 include 事务类：
  //   spi_reg_item.sv / spi_slave_item.sv / spi_bus_trans.sv / spi_exp_trans.sv

  // TODO 4：typedef 两个 sequencer 类型（reg 用 spi_reg_item，slave 用 spi_slave_item）

  // TODO 5：include 寄存器总线组件：driver / monitor / agent

  // TODO 6：include RAL：adapter / reg_block

  // TODO 7：include SPI 侧：slave_driver / bus_monitor

  // TODO 8：include 序列：slave_seq / reg_raw_seq

  // TODO 9：include 分析组件：scoreboard / cov_collector

  // TODO 10：include env / base_test / test_lib

endpackage : spi_pkg
