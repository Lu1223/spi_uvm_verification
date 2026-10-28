// ============================================================================
// spi_cov_collector.sv —— 功能覆盖率收集器（骨架文件）
// 【对应指导文档】docs/09_功能覆盖率收集.md
// 【你要写的】uvm_subscriber + 4 个 covergroup + 按事务类型采样
// ============================================================================
class spi_cov_collector extends uvm_subscriber #(spi_reg_item);

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：uvm_analysis_imp_spi #(spi_bus_trans, spi_cov_collector) spi_imp;
  //         （预留的 SPI 总线采样入口）
  // TODO 3：采样变量：bit en, cpol, cpha; bit[7:0] div, tx; bit busy, rx_valid;

  // TODO 4：covergroup ctrl_cg（en/cpol/cpha + cpol×cpha 交叉）
  //         covergroup div_cg（分桶 {2}, {[3:8]}, {[9:32]}, {[33:255]}）
  //         covergroup txdata_cg（{00}, {FF}, {AA,55}, default 其他）
  //         covergroup status_cg（busy/rx_valid）
  //   每个 covergroup 都要 option.per_instance = 1；

  function new(string name = "spi_cov_collector", uvm_component parent = null);
    // TODO 5：super.new(name, parent);
    // TODO 6：四个 covergroup new()（covergroup 变量必须在构造函数里实例化！）
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // TODO 7：super.build_phase(phase); spi_imp = new("spi_imp", this);
  endfunction

  // TODO 8：write(spi_reg_item item)（uvm_subscriber 的纯虚入口）：
  //   用 case ({item.kind, item.addr}) 分派：
  //     写 CTRL(0x00)  → 取 en/cpol/cpha 三个位，ctrl_cg.sample();
  //     写 DIVIDER(0x04) → div_cg.sample();
  //     写 TX_DATA(0x08) → txdata_cg.sample();
  //     读 STATUS(0x10)  → busy/rx_valid 取值，status_cg.sample();

  // TODO 9：write_spi(spi_bus_trans tr)（spi_imp 回调，本设计留空即可）

endclass : spi_cov_collector
