// ============================================================================
// spi_reg_raw_seq.sv —— 原始总线序列（骨架文件）
// 【对应指导文档】docs/11_test与tb_top.md（corner 测试用到）
// 【你要写的】发送一个 test 手工构造好的 spi_reg_item
// ============================================================================
class spi_reg_raw_seq extends uvm_sequence #(spi_reg_item);

  // TODO 1：`uvm_object_utils 注册
  // TODO 2：spi_reg_item item;   // 由 test 构造好后放进这里
  // TODO 3：new()

  virtual task body();
    // TODO 4：start_item(item); finish_item(item);
  endtask

endclass : spi_reg_raw_seq
