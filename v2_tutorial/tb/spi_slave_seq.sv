// ============================================================================
// spi_slave_seq.sv —— slave 序列（骨架文件）
// 【对应指导文档】docs/07_SPI侧slave模型与总线monitor.md
// 【你要写的】往 slave sequencer 发 count 个 spi_slave_item
// ============================================================================
class spi_slave_seq extends uvm_sequence #(spi_slave_item);

  // TODO 1：`uvm_object_utils 注册（序列是 object！）
  // TODO 2：字段：data[7:0]（回送字节）、count（次数）、cpol、cpha（当前模式）
  // TODO 3：new()

  virtual task body();
    // TODO 4：repeat (count) 循环：
    //   item = spi_slave_item::type_id::create("item");
    //   start_item(item);
    //   item.data = data;  item.cpol = cpol;  item.cpha = cpha;
    //   finish_item(item);
    //   ★ 记住 UVM 规范：先 start_item，再改字段，最后 finish_item！
  endtask

endclass : spi_slave_seq
