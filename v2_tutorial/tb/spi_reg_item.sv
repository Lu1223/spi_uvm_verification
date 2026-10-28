// ============================================================================
// spi_reg_item.sv —— 寄存器总线事务（骨架文件）
// 【对应指导文档】docs/03_spi_reg_item事务类.md
// 【你要写的】读写方向枚举 + 事务类（addr/data/kind + 字段宏 + 地址约束）
// ============================================================================

// TODO 1：定义枚举 spi_kind_e（SPI_WRITE / SPI_READ）

class spi_reg_item extends uvm_sequence_item;

  // TODO 2：声明 rand 字段：addr[7:0]、data[31:0]、kind

  // TODO 3：`uvm_object_utils_begin ... `uvm_object_utils_end
  //   字段宏：addr/data 用 `uvm_field_int，kind 用 `uvm_field_enum

  // TODO 4：new() 构造

  // TODO 5：约束 addr 只能取本 DUT 的 5 个合法地址
  //   {8'h00, 8'h04, 8'h08, 8'h0C, 8'h10}
  //   （注意：非法地址测试用的是 spi_reg_raw_seq 手工构造的 item，不走随机，
  //    约束只作用于随机化，手工赋值不受限）

endclass : spi_reg_item
