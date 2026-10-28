// ============================================================================
// spi_reg_monitor.sv —— 寄存器总线 monitor（骨架文件）
// 【对应指导文档】docs/05_spi_reg_monitor与agent.md
// 【你要写的】analysis port + 观测循环（valid 拍打包 item 广播）
// ============================================================================
class spi_reg_monitor extends uvm_monitor;

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：virtual spi_if vif;  +  uvm_analysis_port #(spi_reg_item) ap;
  // TODO 3：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 4：super.build_phase(phase);
    // TODO 5：ap = new("ap", this);
    // TODO 6：config_db 取 vif（同 driver）
  endfunction

  virtual task run_phase(uvm_phase phase);
    // TODO 7：wait (vif.rst_n === 1'b1);
    // TODO 8：forever 循环：
    //   @(vif.mon_cb);
    //   if (vif.mon_cb.bus_valid) begin
    //     item = spi_reg_item::type_id::create("item");
    //     item.addr = vif.mon_cb.bus_addr;
    //     item.kind = vif.mon_cb.bus_wr ? SPI_WRITE : SPI_READ;
    //     item.data = vif.mon_cb.bus_wr ? vif.mon_cb.bus_wdata
    //                                   : vif.mon_cb.bus_rdata;
    //     ap.write(item);
    //   end
  endtask

endclass : spi_reg_monitor
