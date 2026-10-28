// ============================================================================
// spi_reg_adapter.sv —— RAL 总线适配器（骨架文件）
// 【对应指导文档】docs/06_寄存器模型RAL.md
// 【你要写的】reg2bus / bus2reg 两个翻译函数
// ============================================================================
class spi_reg_adapter extends uvm_reg_adapter;

  // TODO 1：`uvm_object_utils 注册（注意：adapter 是 object 不是 component）

  function new(string name = "spi_reg_adapter");
    super.new(name);
    // TODO 2：provides_responses = 0;
    //   （driver 不回 response，读数据直接写进 item.data 由 bus2reg 取回）
  endfunction

  // TODO 3：reg2bus(const ref uvm_reg_bus_op rw) → 返回 uvm_sequence_item
  //   创建 spi_reg_item，填：
  //     item.addr = rw.addr[7:0];
  //     item.data = rw.data[31:0];
  //     item.kind = (rw.kind == UVM_WRITE) ? SPI_WRITE : SPI_READ;

  // TODO 4：bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw)
  //   $cast 成 spi_reg_item，填 rw.kind/addr/data/status = UVM_IS_OK
  //   （cast 失败 `uvm_fatal）

endclass : spi_reg_adapter
