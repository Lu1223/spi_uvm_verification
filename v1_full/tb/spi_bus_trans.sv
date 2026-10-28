// ============================================================================
// spi_bus_trans.sv —— SPI 总线观测事务
// spi_bus_monitor 在每次传输结束后广播：master 发出的字节 + slave 发出的字节
// ============================================================================
class spi_bus_trans extends uvm_sequence_item;

  bit [7:0] mosi_byte;   // 本次传输 master 发出的字节（monitor 在 sclk 上升沿逐位采集）
  bit [7:0] miso_byte;   // 本次传输 slave 发出的字节

  `uvm_object_utils_begin(spi_bus_trans)
    `uvm_field_int(mosi_byte, UVM_ALL_ON)
    `uvm_field_int(miso_byte, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_bus_trans");
    super.new(name);
  endfunction

endclass : spi_bus_trans
