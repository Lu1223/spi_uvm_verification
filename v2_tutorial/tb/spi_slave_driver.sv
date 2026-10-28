// ============================================================================
// spi_slave_driver.sv —— SPI slave 模型（骨架文件）
// 【对应指导文档】docs/07_SPI侧slave模型与总线monitor.md
// 【你要写的】按模式逐位移出字节的时序（本文件是整个环境最考时序的部分）
// ============================================================================
class spi_slave_driver extends uvm_driver #(spi_slave_item);

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：virtual spi_if vif;  +  uvm_analysis_port #(spi_slave_item) slave_byte_ap;
  // TODO 3：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 4：super.build_phase(phase);
    // TODO 5：slave_byte_ap = new("slave_byte_ap", this);
    // TODO 6：config_db 取 vif
  endfunction

  virtual task run_phase(uvm_phase phase);
    // TODO 7：wait (vif.rst_n === 1'b1);  vif.spi_miso <= 1'b0;（空闲拉 0 防 X）
    // TODO 8：forever 循环：
    //   seq_item_port.get_next_item(item);
    //   do_transfer(item);
    //   slave_byte_ap.write(item);   // 自报实际发送的字节 → scoreboard
    //   seq_item_port.item_done();
  endtask

  // TODO 9：do_transfer 时序（核心，推导见指导文档 07）：
  //   移位沿 = (cpol ^ cpha) ? 上升沿 : 下降沿   ← master 的移位沿
  //   采样沿 = (cpol == cpha) ? 上升沿 : 下降沿  ← master 的采样沿（monitor 用）
  //
  //   bit shift_is_rise = item.cpol ^ item.cpha;
  //   int first_shift   = item.cpha;      // CPHA=1 要先空等一个移位沿
  //
  //   @(negedge vif.spi_cs_n);            // 等传输开始
  //   vif.spi_miso <= item.data[7];       // 首 bit：cs 拉低即送出
  //   for (int i = 0; i < 7 + first_shift; i++) begin
  //     if (shift_is_rise) @(posedge vif.spi_sclk);
  //     else               @(negedge vif.spi_sclk);
  //     if (i >= first_shift)
  //       vif.spi_miso <= item.data[6 - (i - first_shift)];
  //   end
  //   @(posedge vif.spi_cs_n);            // 等传输结束
  //
  //   ★ 为什么 CPHA=1 要跳第一个移位沿？因为 CPHA=1 时 master 的第一个移位沿
  //     （前沿）出现在首次采样（后沿）之前，slave 若在它上面换 bit6，
  //     master 首次采样到的就不是 bit7 了

endclass : spi_slave_driver
