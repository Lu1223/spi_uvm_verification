// ============================================================================
// spi_if.sv —— 统一接口（骨架文件）
// 【对应指导文档】docs/02_搭建spi_if接口.md
// 【你要写的】接口信号声明 + driver/monitor 两个时序块
// ============================================================================
interface spi_if (input logic clk, input logic rst_n);

  // TODO 1：声明寄存器总线信号（bus_valid/addr/wdata/wr/ready/rdata）
  //   提示：被 DUT 输出驱动的信号（bus_ready/bus_rdata）不能有初始化赋值！
  //   只有 TB 侧驱动的信号（bus_valid/addr/wdata/wr）可以写 = 初始值

  // TODO 2：声明 SPI 引脚（spi_sclk/cs_n/mosi 是 DUT 输出；spi_miso 由 TB 的
  //   slave 模型驱动，可以给初始值 = 1'b0 避免 X）

  // TODO 3：写 driver 时序块 drv_cb：
  //   clocking drv_cb @(posedge clk);
  //     default input #1step output #1ns;   // 输出加 1ns 延迟防竞争
  //     output bus_valid, bus_addr, bus_wdata, bus_wr;
  //     input  bus_ready, bus_rdata;
  //   endclocking

  // TODO 4：写 monitor 时序块 mon_cb（全部 input #1step）

endinterface : spi_if
