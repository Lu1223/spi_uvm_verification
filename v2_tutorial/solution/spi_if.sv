// ============================================================================
// spi_if.sv —— 验证平台统一接口
// 包含两部分：
//   1. 寄存器总线信号（bus_*）+ 驱动/监测时序块（clocking block）
//   2. SPI 引脚（spi_*），SPI 侧组件用事件等待方式直接操作，不用时序块
// ============================================================================
interface spi_if (input logic clk, input logic rst_n);

  // ---- 简易同步寄存器总线 ----
  // 注意：被 DUT 输出驱动的信号（bus_ready/bus_rdata）不能有初始化赋值
  logic        bus_valid = 1'b0;   // TB 驱动
  logic [7:0]  bus_addr  = 8'h00;  // TB 驱动
  logic [31:0] bus_wdata = 32'h0;  // TB 驱动
  logic        bus_wr    = 1'b0;   // TB 驱动
  logic        bus_ready;          // DUT 输出
  logic [31:0] bus_rdata;          // DUT 输出

  // ---- SPI 引脚 ----
  logic spi_sclk;    // DUT 输出
  logic spi_cs_n;    // DUT 输出
  logic spi_mosi;    // DUT 输出
  logic spi_miso = 1'b0;   // 由 slave 模型驱动（TB 侧）

  // ---- driver 时序块：输出在 posedge 后 #1ns 驱动，输入 #1step 采样 ----
  clocking drv_cb @(posedge clk);
    default input #1step output #1ns;
    output bus_valid, bus_addr, bus_wdata, bus_wr;
    input  bus_ready, bus_rdata;
  endclocking : drv_cb

  // ---- monitor 时序块：全部 #1step 采样（采到稳定值） ----
  clocking mon_cb @(posedge clk);
    default input #1step;
    input bus_valid, bus_addr, bus_wdata, bus_wr, bus_ready, bus_rdata;
  endclocking : mon_cb

endinterface : spi_if
