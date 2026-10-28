// ============================================================================
// spi_slave_item.sv —— slave 模型事务
// 一个 item = slave 在下次传输中要放到 MISO 上的字节
// 附带 cpol/cpha：slave 模型需要知道模式才能选对移位沿
// ============================================================================
class spi_slave_item extends uvm_sequence_item;

  bit [7:0] data;    // slave 要回送的字节
  bit       cpol;    // 当前 SPI 模式（由 test 配置）
  bit       cpha;

  `uvm_object_utils_begin(spi_slave_item)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(cpol, UVM_ALL_ON)
    `uvm_field_int(cpha, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_slave_item");
    super.new(name);
  endfunction

endclass : spi_slave_item
