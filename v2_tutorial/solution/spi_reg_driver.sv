// ============================================================================
// spi_reg_driver.sv —— 寄存器总线 driver
// 从 sequencer 拿 spi_reg_item，通过 clocking block 驱动总线
// 写：驱动一拍（valid+addr+wdata+wr），下一拍撤销 valid
// 读：驱动一拍，下一拍采样 bus_rdata（DUT 组合读，当拍已稳定）
// ============================================================================
class spi_reg_driver extends uvm_driver #(spi_reg_item);

  `uvm_component_utils(spi_reg_driver)

  virtual spi_if vif;

  function new(string name = "spi_reg_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "spi_reg_driver: 未能从 config_db 获取 virtual spi_if")
  endfunction

  virtual task run_phase(uvm_phase phase);
    spi_reg_item item;
    wait (vif.rst_n === 1'b1);          // 等复位释放
    forever begin
      seq_item_port.get_next_item(item);
      case (item.kind)
        SPI_WRITE : bus_write(item.addr, item.data);
        SPI_READ  : bus_read (item.addr, item.data);
        default   : `uvm_error("DRV", $sformatf("未知 kind: %s", item.kind.name()))
      endcase
      seq_item_port.item_done();
    end
  endtask

  // ---- 单周期写 ----
  virtual task bus_write(input bit [7:0] addr, input bit [31:0] data);
    @(vif.drv_cb);
    vif.drv_cb.bus_valid <= 1'b1;
    vif.drv_cb.bus_addr  <= addr;
    vif.drv_cb.bus_wdata <= data;
    vif.drv_cb.bus_wr    <= 1'b1;
    @(vif.drv_cb);
    vif.drv_cb.bus_valid <= 1'b0;
  endtask

  // ---- 单周期读 ----
  virtual task bus_read(input bit [7:0] addr, output bit [31:0] data);
    @(vif.drv_cb);
    vif.drv_cb.bus_valid <= 1'b1;
    vif.drv_cb.bus_addr  <= addr;
    vif.drv_cb.bus_wr    <= 1'b0;
    @(vif.drv_cb);
    data = vif.drv_cb.bus_rdata;        // 读数据在第二拍采样
    vif.drv_cb.bus_valid <= 1'b0;
  endtask

endclass : spi_reg_driver
