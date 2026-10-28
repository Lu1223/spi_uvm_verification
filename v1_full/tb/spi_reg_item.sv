// ============================================================================
// spi_reg_item.sv —— 寄存器总线事务
// 一次总线读写 = 一个 item：driver 消费它驱动总线，monitor 观测总线后广播它
// ============================================================================
typedef enum bit { SPI_WRITE, SPI_READ } spi_kind_e;

class spi_reg_item extends uvm_sequence_item;

  rand bit [7:0]  addr;    // 寄存器地址
  rand bit [31:0] data;    // 写：写数据；读：读回数据
  rand spi_kind_e kind;    // 读写方向

  `uvm_object_utils_begin(spi_reg_item)
    `uvm_field_int (addr, UVM_ALL_ON)
    `uvm_field_int (data, UVM_ALL_ON)
    `uvm_field_enum(spi_kind_e, kind, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_reg_item");
    super.new(name);
  endfunction

  // 本 DUT 只有 5 个合法寄存器地址
  constraint c_addr {
    addr inside {8'h00, 8'h04, 8'h08, 8'h0C, 8'h10};
  }

endclass : spi_reg_item
