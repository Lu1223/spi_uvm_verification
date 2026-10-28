// ============================================================================
// spi_slave_seq.sv —— slave 序列
// 往 slave sequencer 上发 count 个 spi_slave_item（每个 item 一个字节）
// ============================================================================
class spi_slave_seq extends uvm_sequence #(spi_slave_item);

  `uvm_object_utils(spi_slave_seq)

  bit [7:0]    data;    // slave 要回送的字节
  int unsigned count;   // 连续回送的次数
  bit          cpol;    // 当前 SPI 模式
  bit          cpha;

  function new(string name = "spi_slave_seq");
    super.new(name);
  endfunction

  virtual task body();
    spi_slave_item item;
    repeat (count) begin
      item = spi_slave_item::type_id::create("item");
      start_item(item);
      item.data = data;
      item.cpol = cpol;
      item.cpha = cpha;
      finish_item(item);
    end
  endtask

endclass : spi_slave_seq
