// ============================================================================
// spi_bus_trans.sv —— SPI 总线观测事务（骨架文件）
// 【对应指导文档】docs/07_SPI侧slave模型与总线monitor.md
// 【你要写的】mosi_byte/miso_byte 两个字段 + 字段宏
// ============================================================================
class spi_bus_trans extends uvm_sequence_item;

  // TODO 1：mosi_byte[7:0] —— 本次传输 master 发出的字节
  // TODO 2：miso_byte[7:0] —— 本次传输 slave 发出的字节

  // TODO 3：`uvm_object_utils 字段宏 + new()

endclass : spi_bus_trans
