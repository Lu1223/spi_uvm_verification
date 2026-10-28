// ============================================================================
// spi_slave_item.sv —— slave 模型事务（骨架文件）
// 【对应指导文档】docs/07_SPI侧slave模型与总线monitor.md
// 【你要写的】data/cpol/cpha 三个字段 + 字段宏
// ============================================================================
class spi_slave_item extends uvm_sequence_item;

  // TODO 1：data[7:0] —— slave 要回送的字节
  // TODO 2：cpol/cpha —— 当前 SPI 模式（slave 选移位沿要用，由 test 经 sequence 带入）

  // TODO 3：`uvm_object_utils 字段宏 + new()

endclass : spi_slave_item
