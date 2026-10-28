// ============================================================================
// spi_tb_top.sv —— 测试平台顶层（骨架文件）
// 【对应指导文档】docs/11_test与tb_top.md
// 【你要写的】时钟复位 + DUT 例化连线 + config_db + fsdb + run_test + 看门狗
// ============================================================================
module spi_tb_top;

  // TODO 1：import uvm_pkg::*; `include "uvm_macros.svh"; import spi_pkg::*;

  // TODO 2：时钟 100MHz（initial: clk=0; forever #5 clk=~clk;）
  // TODO 3：复位：低 10 拍后拉高（repeat(10) @(posedge clk); rst_n=1;）

  // TODO 4：spi_if vif (clk, rst_n);
  // TODO 5：spi_master dut 例化，端口接到 vif 的信号上：
  //   .clk(clk) .rst_n(rst_n)
  //   .bus_valid(vif.bus_valid) ...（总线 6 个信号）
  //   .spi_sclk(vif.spi_sclk) ...（SPI 4 个信号）

  // TODO 6：initial begin
  //   $fsdbDumpfile("simv.fsdb");
  //   $fsdbDumpvars(0, spi_tb_top, "+all");
  //   uvm_config_db #(virtual spi_if)::set(null, "*", "vif", vif);
  //   run_test();
  // end

  // TODO 7：看门狗 initial：10ms 后 `uvm_fatal("TB", "WATCHDOG TIMEOUT...")
  //   （corner 的 div=255 传输约 41us，10ms 余量充足）

endmodule : spi_tb_top
