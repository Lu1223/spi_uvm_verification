// ============================================================================
// spi_pkg.sv —— SPI 验证环境统一包
// 所有 UVM 组件定义在本包内；tb_top 用 import spi_pkg::* 引用
// 注意：spi_if.sv 接口定义在本文件之外（filelist 中编译顺序靠前）
// ============================================================================
package spi_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------- analysis imp 宏声明（必须先于使用声明） ----------------
  `uvm_analysis_imp_decl(_reg)
  `uvm_analysis_imp_decl(_spi)
  `uvm_analysis_imp_decl(_slave)

  // ---------------- 事务类 ----------------
  `include "spi_reg_item.sv"     // 寄存器总线事务
  `include "spi_slave_item.sv"   // slave 模型事务（要回送的字节）
  `include "spi_bus_trans.sv"    // SPI 总线观测事务（一次传输的 mosi/miso 字节）
  `include "spi_exp_trans.sv"    // scoreboard 期望事务

  // ---------------- sequencer 类型 ----------------
  typedef uvm_sequencer #(spi_reg_item)   spi_reg_sequencer;
  typedef uvm_sequencer #(spi_slave_item) spi_slave_sequencer;

  // ---------------- 寄存器总线 agent ----------------
  `include "spi_reg_driver.sv"
  `include "spi_reg_monitor.sv"
  `include "spi_reg_agent.sv"

  // ---------------- 寄存器模型（RAL） ----------------
  `include "spi_reg_adapter.sv"
  `include "spi_reg_block.sv"

  // ---------------- SPI 侧（slave 模型 + 总线 monitor） ----------------
  `include "spi_slave_driver.sv"
  `include "spi_bus_monitor.sv"

  // ---------------- 序列 ----------------
  `include "spi_slave_seq.sv"
  `include "spi_reg_raw_seq.sv"

  // ---------------- scoreboard / coverage ----------------
  `include "spi_scoreboard.sv"
  `include "spi_cov_collector.sv"

  // ---------------- env / test ----------------
  `include "spi_env.sv"
  `include "spi_base_test.sv"
  `include "spi_test_lib.sv"

endpackage : spi_pkg
