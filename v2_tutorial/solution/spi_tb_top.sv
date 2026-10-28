// ============================================================================
// spi_tb_top.sv —— 测试平台顶层
// 职责：
//   1. 生成时钟（100MHz）与复位（低 10 拍后释放）
//   2. 例化 interface 和 DUT，完成信号连线
//   3. 把 virtual interface 放进 config_db（通配 "*" 让所有 UVM 组件可见）
//   4. 导出 FSDB 波形（Verdi 查看）
//   5. run_test() 启动 UVM（+UVM_TESTNAME=xxx 指定测试）
//   6. 看门狗：10ms 未结束视为挂死
// ============================================================================
module spi_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import spi_pkg::*;

  // ------------------- 时钟与复位 -------------------
  logic clk;
  logic rst_n;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;          // 周期 10ns = 100MHz
  end

  initial begin
    rst_n = 1'b0;                   // 复位 10 拍（100ns）
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // ------------------- interface 与 DUT -------------------
  spi_if vif (clk, rst_n);

  spi_master dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .bus_valid (vif.bus_valid),
    .bus_addr  (vif.bus_addr),
    .bus_wdata (vif.bus_wdata),
    .bus_wr    (vif.bus_wr),
    .bus_ready (vif.bus_ready),
    .bus_rdata (vif.bus_rdata),
    .spi_sclk  (vif.spi_sclk),
    .spi_cs_n  (vif.spi_cs_n),
    .spi_mosi  (vif.spi_mosi),
    .spi_miso  (vif.spi_miso)
  );

  // ------------------- UVM 启动 + FSDB 波形 -------------------
  initial begin
    // 波形导出：全层级、全信号（Verdi 用 simv.fsdb 查看）
    $fsdbDumpfile("simv.fsdb");
    $fsdbDumpvars(0, spi_tb_top, "+all");

    // virtual interface 放入 config_db，通配 "*" 让所有 UVM 组件可见
    uvm_config_db #(virtual spi_if)::set(null, "*", "vif", vif);

    // 启动测试（+UVM_TESTNAME=xxx 在 Makefile/命令行指定）
    run_test();
  end

  // ------------------- 看门狗：10ms 未结束视为挂死 -------------------
  initial begin
    #10_000_000ns;
    `uvm_fatal("TB", "WATCHDOG TIMEOUT: simulation stuck > 10ms!")
  end

endmodule : spi_tb_top
