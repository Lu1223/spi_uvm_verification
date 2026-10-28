// ============================================================================
// spi_reg_raw_seq.sv —— 原始总线序列
// 用于发送 RAL 无法覆盖的总线事务（如非法地址访问）：
// test 先构造好 spi_reg_item 放进 seq.item，再 start 到 reg sequencer 上
// ============================================================================
class spi_reg_raw_seq extends uvm_sequence #(spi_reg_item);

  `uvm_object_utils(spi_reg_raw_seq)

  spi_reg_item item;    // 要发送的总线事务（由 test 构造）

  function new(string name = "spi_reg_raw_seq");
    super.new(name);
  endfunction

  virtual task body();
    start_item(item);
    finish_item(item);
  endtask

endclass : spi_reg_raw_seq
