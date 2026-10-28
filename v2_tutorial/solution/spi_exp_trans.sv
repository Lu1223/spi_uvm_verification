// ============================================================================
// spi_exp_trans.sv —— scoreboard 期望事务
// test 在发起传输前把"期望发生什么"推给 scoreboard：
//   tx_byte    —— 期望 master 发出的字节（= 写入 TX_DATA 的值）
//   slave_byte —— 期望 slave 回送的字节
// scoreboard 仿真结束后把期望与实测逐一比对
// ============================================================================
class spi_exp_trans extends uvm_sequence_item;

  bit [7:0] tx_byte;
  bit [7:0] slave_byte;

  `uvm_object_utils_begin(spi_exp_trans)
    `uvm_field_int(tx_byte,    UVM_ALL_ON)
    `uvm_field_int(slave_byte, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_exp_trans");
    super.new(name);
  endfunction

endclass : spi_exp_trans
