// ============================================================================
// spi_slave_driver.sv —— SPI slave 模型
// 扮演 DUT（SPI master）的对端设备：
//   1. 从 sequencer 拿到要回送的字节
//   2. 等 cs_n 拉低（一次传输开始）
//   3. 第一拍把 bit7 放到 MISO 上，之后每个 sclk 上升沿送出下一位
//      （该时序对 CPOL/CPHA 四种模式都成立，推导见 docs/02_验证计划与验证框图.md）
//   4. cs_n 拉高后把实际发送的字节广播给 scoreboard
// ============================================================================
class spi_slave_driver extends uvm_driver #(spi_slave_item);

  `uvm_component_utils(spi_slave_driver)

  virtual spi_if vif;
  uvm_analysis_port #(spi_slave_item) slave_byte_ap;  // slave 实际发送字节 → scoreboard

  function new(string name = "spi_slave_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    slave_byte_ap = new("slave_byte_ap", this);
    if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "spi_slave_driver: 未能从 config_db 获取 virtual spi_if")
  endfunction

  virtual task run_phase(uvm_phase phase);
    spi_slave_item item;
    wait (vif.rst_n === 1'b1);
    vif.spi_miso <= 1'b0;               // 空闲时 MISO 保持 0，避免 X
    forever begin
      seq_item_port.get_next_item(item);
      do_transfer(item);
      slave_byte_ap.write(item);        // 报告 slave 实际发送的字节
      seq_item_port.item_done();
    end
  endtask

  // slave 发送时序（对四种 CPOL/CPHA 模式都成立）：
  //   1. cs_n 拉低时先把 bit7 放到 MISO 上
  //   2. 之后在"master 的移位沿"上送出下一位：
  //        移位沿 = 采样沿的相反边沿 = (cpol^cpha) ? 上升沿 : 下降沿
  //   3. CPHA=1 时第一个移位沿出现在首次采样之前，必须跳过（保持 bit7）
  //   推导过程见 docs/02_验证计划与验证框图.md
  virtual task do_transfer(spi_slave_item item);
    bit shift_is_rise = item.cpol ^ item.cpha;
    int first_shift   = item.cpha;      // CPHA=1 先空等一个移位沿
    @(negedge vif.spi_cs_n);            // 等一次传输开始
    vif.spi_miso <= item.data[7];       // 首 bit：cs 拉低即送出
    for (int i = 0; i < 7 + first_shift; i++) begin
      if (shift_is_rise) @(posedge vif.spi_sclk);
      else               @(negedge vif.spi_sclk);
      if (i >= first_shift)
        vif.spi_miso <= item.data[6 - (i - first_shift)];
    end
    @(posedge vif.spi_cs_n);            // 等传输结束（cs 拉高）
  endtask

endclass : spi_slave_driver
