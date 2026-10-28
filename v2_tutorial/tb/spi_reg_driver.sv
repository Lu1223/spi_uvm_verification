// ============================================================================
// spi_reg_driver.sv —— 寄存器总线 driver（骨架文件）
// 【对应指导文档】docs/04_spi_reg_driver驱动器.md
// 【你要写的】config_db 取 vif + get_next_item/item_done 循环 + 单周期读/写任务
// ============================================================================
class spi_reg_driver extends uvm_driver #(spi_reg_item);

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：virtual spi_if vif;
  // TODO 3：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 4：super.build_phase(phase);
    // TODO 5：uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)
    //         取不到就 `uvm_fatal
  endfunction

  virtual task run_phase(uvm_phase phase);
    // TODO 6：wait (vif.rst_n === 1'b1);  等复位释放
    // TODO 7：forever 循环：
    //   seq_item_port.get_next_item(item);
    //   case (item.kind)
    //     SPI_WRITE: bus_write(item.addr, item.data);
    //     SPI_READ : bus_read (item.addr, item.data);
    //   endcase
    //   seq_item_port.item_done();
  endtask

  // TODO 8：写任务 bus_write（两拍：第一拍驱动 valid+addr+wdata+wr，第二拍撤 valid）
  //   @(vif.drv_cb);
  //   vif.drv_cb.bus_valid <= 1'b1;  ... 驱动各信号
  //   @(vif.drv_cb);
  //   vif.drv_cb.bus_valid <= 1'b0;
  //   （注意：时序块信号要写 vif.drv_cb.xxx，不是 vif.xxx）

  // TODO 9：读任务 bus_read（第一拍驱动 valid+addr+wr=0；
  //   第二拍采样 vif.drv_cb.bus_rdata 到 data 输出参数，再撤 valid）
  //   提示：DUT 读是组合逻辑，第一拍驱动后第二拍 rdata 已稳定

endclass : spi_reg_driver
