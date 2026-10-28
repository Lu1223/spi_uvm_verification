// ============================================================================
// spi_bus_monitor.sv —— SPI 总线 monitor（骨架文件）
// 【对应指导文档】docs/07_SPI侧slave模型与总线monitor.md
// 【你要写的】在 master 采样沿逐位采集 mosi/miso，8 bit 后广播
// ============================================================================
class spi_bus_monitor extends uvm_monitor;

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：virtual spi_if vif;  +  uvm_analysis_port #(spi_bus_trans) ap;
  // TODO 3：bit cur_cpol, cur_cpha;   // 当前模式（test 通过 set_mode 通知）
  // TODO 4：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 5：super.build_phase(phase); ap = new("ap", this); config_db 取 vif
  endfunction

  // TODO 6：set_mode(bit cpol, bit cpha) —— 保存当前模式
  //   （test 在每次 cfg_mode 时调用；monitor 在 cs 拉低时读取）

  virtual task run_phase(uvm_phase phase);
    // TODO 7：wait (vif.rst_n === 1'b1);
    // TODO 8：forever 循环：
    //   @(negedge vif.spi_cs_n);           // 一次传输开始
    //   sample_is_rise = ~(cur_cpol ^ cur_cpha);   // master 采样沿
    //   tr = spi_bus_trans::type_id::create("tr");
    //   for (int i = 0; i < 8; i++) begin
    //     if (sample_is_rise) @(posedge vif.spi_sclk);
    //     else                @(negedge vif.spi_sclk);
    //     tr.mosi_byte = {tr.mosi_byte[6:0], vif.spi_mosi};  // MSB 在前
    //     tr.miso_byte = {tr.miso_byte[6:0], vif.spi_miso};
    //   end
    //   ap.write(tr);   // 立即广播，不要等 cs 拉高！
    //                   // （CPOL=1 时第 8 个采样沿与 cs 拉高同拍，等 cs 会错过事件）
    //
    //   ★ 为什么在"采样沿"采？该边沿上 master/slave 都不改变数据，
    //     读到的一定是本拍实际传输的 bit，无竞争

  endtask

endclass : spi_bus_monitor
