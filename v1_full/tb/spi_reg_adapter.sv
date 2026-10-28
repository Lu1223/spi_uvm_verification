// ============================================================================
// spi_reg_adapter.sv —— RAL 总线适配器
// 作用：把 RAL 的 uvm_reg_bus_op（寄存器级操作）翻译成 spi_reg_item（总线事务）
//       以及反向翻译（predictor 用）
// ============================================================================
class spi_reg_adapter extends uvm_reg_adapter;

  `uvm_object_utils(spi_reg_adapter)

  function new(string name = "spi_reg_adapter");
    super.new(name);
    // driver 不回 response：读数据直接写进 item.data，由 bus2reg 取回
    provides_responses = 0;
  endfunction

  // RAL 操作 → 总线事务
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    spi_reg_item item = spi_reg_item::type_id::create("item");
    item.addr = rw.addr[7:0];
    item.data = rw.data[31:0];
    item.kind = (rw.kind == UVM_WRITE) ? SPI_WRITE : SPI_READ;
    return item;
  endfunction

  // 总线事务 → RAL 操作（读操作由 driver 把读回数据填进 item.data）
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    spi_reg_item item;
    if (!$cast(item, bus_item)) begin
      `uvm_fatal("ADAPTER", "bus2reg: bus_item 不是 spi_reg_item 类型")
    end
    rw.kind   = (item.kind == SPI_WRITE) ? UVM_WRITE : UVM_READ;
    rw.addr   = item.addr;
    rw.data   = item.data;
    rw.status = UVM_IS_OK;
  endfunction

endclass : spi_reg_adapter
