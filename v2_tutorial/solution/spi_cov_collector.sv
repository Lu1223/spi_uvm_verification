// ============================================================================
// spi_cov_collector.sv —— 功能覆盖率收集器
// 订阅寄存器总线事务（uvm_subscriber），在合法事务上采样覆盖组：
//   ctrl_cg   ：en / cpol / cpha / cpol×cpha 交叉（四种 SPI 模式必须全跑到）
//   div_cg    ：分频值分桶（最快/小/中/大）
//   txdata_cg ：发送数据（全 0 / 全 1 / 交替 / 其他）
//   status_cg ：busy / rx_valid 观测到的状态（0 和 1 都要出现）
// 仿真结束 UVM 自动打印各 covergroup 覆盖率汇总
// ============================================================================
class spi_cov_collector extends uvm_subscriber #(spi_reg_item);

  `uvm_component_utils(spi_cov_collector)

  // 第二个订阅入口：SPI 总线事务（预留总线级数据覆盖）
  uvm_analysis_imp_spi #(spi_bus_trans, spi_cov_collector) spi_imp;

  // ---- 采样变量 ----
  bit       en, cpol, cpha;
  bit [7:0] div;
  bit [7:0] tx;
  bit       busy, rx_valid;

  // ---- 覆盖组 1：控制寄存器 ----
  covergroup ctrl_cg;
    option.per_instance = 1;
    cp_en   : coverpoint en;
    cp_cpol : coverpoint cpol;
    cp_cpha : coverpoint cpha;
    cp_mode : cross cp_cpol, cp_cpha;   // 四种 SPI 模式交叉
  endgroup : ctrl_cg

  // ---- 覆盖组 2：分频值 ----
  covergroup div_cg;
    option.per_instance = 1;
    cp_div : coverpoint div {
      bins div_min   = {8'd2};           // 最快
      bins div_small = {[8'd3:8'd8]};
      bins div_mid   = {[8'd9:8'd32]};
      bins div_big   = {[8'd33:8'd255]}; // 最慢
    }
  endgroup : div_cg

  // ---- 覆盖组 3：发送数据 ----
  covergroup txdata_cg;
    option.per_instance = 1;
    cp_tx : coverpoint tx {
      bins tx_zero   = {8'h00};          // 全 0
      bins tx_ff     = {8'hFF};          // 全 1
      bins tx_walk   = {8'hAA, 8'h55};   // 0/1 交替
      bins tx_others = default;          // 其余随机值
    }
  endgroup : txdata_cg

  // ---- 覆盖组 4：状态位 ----
  covergroup status_cg;
    option.per_instance = 1;
    cp_busy     : coverpoint busy;
    cp_rx_valid : coverpoint rx_valid;
  endgroup : status_cg

  function new(string name = "spi_cov_collector", uvm_component parent = null);
    super.new(name, parent);
    ctrl_cg   = new();
    div_cg    = new();
    txdata_cg = new();
    status_cg = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    spi_imp = new("spi_imp", this);
  endfunction

  // ---- 寄存器总线观测采样（uvm_subscriber 入口） ----
  virtual function void write(spi_reg_item item);
    case ({item.kind, item.addr})
      {SPI_WRITE, 8'h00}: begin
        en   = item.data[0];
        cpol = item.data[1];
        cpha = item.data[2];
        ctrl_cg.sample();
      end
      {SPI_WRITE, 8'h04}: begin
        div = item.data[7:0];
        div_cg.sample();
      end
      {SPI_WRITE, 8'h08}: begin
        tx = item.data[7:0];
        txdata_cg.sample();
      end
      {SPI_READ, 8'h10}: begin
        busy     = item.data[0];
        rx_valid = item.data[1];
        status_cg.sample();
      end
      default: ;
    endcase
  endfunction

  // ---- SPI 总线观测（预留） ----
  virtual function void write_spi(spi_bus_trans tr);
    // 可在此添加总线级数据覆盖，例如 mosi/miso 字节分布
  endfunction

endclass : spi_cov_collector
