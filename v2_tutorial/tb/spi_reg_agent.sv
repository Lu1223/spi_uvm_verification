// ============================================================================
// spi_reg_agent.sv —— 寄存器总线 agent（骨架文件）
// 【对应指导文档】docs/05_spi_reg_monitor与agent.md
// 【你要写的】打包 driver/monitor/sequencer，is_active 控制
// ============================================================================
class spi_reg_agent extends uvm_agent;

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：声明成员：spi_reg_driver driver; spi_reg_monitor monitor;
  //         spi_reg_sequencer sequencer;（typedef 在 pkg 里）
  // TODO 3：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 4：super.build_phase(phase);
    // TODO 5：monitor 无条件创建
    // TODO 6：if (get_is_active() == UVM_ACTIVE) 创建 driver 和 sequencer
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    // TODO 7：super.connect_phase(phase);
    // TODO 8：active 时 driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : spi_reg_agent
