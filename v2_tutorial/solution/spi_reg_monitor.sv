// ============================================================================
// spi_reg_monitor.sv —— 寄存器总线 monitor
// 被动观测总线：每个 valid 拍打包一个 spi_reg_item 广播到 analysis port
// （下游：RAL predictor 更新镜像、scoreboard、coverage）
// ============================================================================
class spi_reg_monitor extends uvm_monitor;

  `uvm_component_utils(spi_reg_monitor)

  virtual spi_if vif;
  uvm_analysis_port #(spi_reg_item) ap;

  function new(string name = "spi_reg_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "spi_reg_monitor: 未能从 config_db 获取 virtual spi_if")
  endfunction

  virtual task run_phase(uvm_phase phase);
    spi_reg_item item;
    wait (vif.rst_n === 1'b1);
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.bus_valid) begin
        item = spi_reg_item::type_id::create("item");
        item.addr = vif.mon_cb.bus_addr;
        item.kind = vif.mon_cb.bus_wr ? SPI_WRITE : SPI_READ;
        item.data = vif.mon_cb.bus_wr ? vif.mon_cb.bus_wdata : vif.mon_cb.bus_rdata;
        ap.write(item);
      end
    end
  endtask

endclass : spi_reg_monitor
