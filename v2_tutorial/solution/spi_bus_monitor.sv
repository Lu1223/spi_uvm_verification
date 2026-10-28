// ============================================================================
// spi_bus_monitor.sv —— SPI 总线 monitor
// 被动观测 SPI 引脚：一次传输（cs_n 拉低到拉高）打包一个 spi_bus_trans
// 采集方案：在"master 的采样沿"逐位采集 mosi / miso（MSB 在前）
//   采样沿 = (cpha==cpol) ? 上升沿 : 下降沿
//   该边沿上 master/slave 都不改变数据 → 采到的就是本拍实际传输的 bit
// 模式来源：test 在配置模式时调用 set_mode() 通知 monitor
// 8 个采样沿凑齐一个字节后立即广播（不等待 cs 拉高：
//   CPOL=1 时第 8 个采样沿可能与 cs 拉高同拍，等 cs 会错过事件）
// ============================================================================
class spi_bus_monitor extends uvm_monitor;

  `uvm_component_utils(spi_bus_monitor)

  virtual spi_if vif;
  uvm_analysis_port #(spi_bus_trans) ap;

  bit cur_cpol;    // 当前模式（由 test 通过 set_mode 通知）
  bit cur_cpha;

  function new(string name = "spi_bus_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "spi_bus_monitor: 未能从 config_db 获取 virtual spi_if")
  endfunction

  // test 在每次配置 SPI 模式后调用
  function void set_mode(bit cpol, bit cpha);
    cur_cpol = cpol;
    cur_cpha = cpha;
  endfunction

  virtual task run_phase(uvm_phase phase);
    spi_bus_trans tr;
    bit sample_is_rise;
    wait (vif.rst_n === 1'b1);
    forever begin
      @(negedge vif.spi_cs_n);          // 一次传输开始
      sample_is_rise = ~(cur_cpol ^ cur_cpha);
      tr = spi_bus_trans::type_id::create("tr");
      for (int i = 0; i < 8; i++) begin
        if (sample_is_rise) @(posedge vif.spi_sclk);
        else                @(negedge vif.spi_sclk);
        tr.mosi_byte = {tr.mosi_byte[6:0], vif.spi_mosi};
        tr.miso_byte = {tr.miso_byte[6:0], vif.spi_miso};
      end
      ap.write(tr);                     // 立即广播，不等待 cs 拉高
    end
  endtask

endclass : spi_bus_monitor
