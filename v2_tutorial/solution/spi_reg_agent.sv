// ============================================================================
// spi_reg_agent.sv —— 寄存器总线 agent
// 把 driver / monitor / sequencer 打包成一个组件
// is_active = UVM_ACTIVE（默认）时创建 driver 和 sequencer
// ============================================================================
class spi_reg_agent extends uvm_agent;

  `uvm_component_utils(spi_reg_agent)

  spi_reg_driver    driver;
  spi_reg_monitor   monitor;
  spi_reg_sequencer sequencer;

  function new(string name = "spi_reg_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = spi_reg_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      driver    = spi_reg_driver::type_id::create("driver", this);
      sequencer = spi_reg_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : spi_reg_agent
