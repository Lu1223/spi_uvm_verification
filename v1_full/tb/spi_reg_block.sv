// ============================================================================
// spi_reg_block.sv —— RAL 寄存器模型
// 与 DUT 寄存器一一对应：
//   0x00 CTRL    : en[0] RW / cpol[1] RW / cpha[2] RW / rsvd[7:3] RO
//   0x04 DIVIDER : div[7:0] RW（复位值 8，与 DUT 一致）
//   0x08 TX_DATA : tx[7:0] RW
//   0x0C RX_DATA : rx[7:0] RO
//   0x10 STATUS  : busy[0] RO / rx_valid[1] RO / rsvd[7:2] RO
// ============================================================================

// ---- 0x00 CTRL ----
class spi_ctrl_reg extends uvm_reg;

  rand uvm_reg_field en;      // [0] 使能
  rand uvm_reg_field cpol;    // [1] 时钟极性
  rand uvm_reg_field cpha;    // [2] 时钟相位
  rand uvm_reg_field rsvd;    // [7:3]

  `uvm_object_utils(spi_ctrl_reg)

  function new(string name = "spi_ctrl_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    en   = uvm_reg_field::type_id::create("en");
    cpol = uvm_reg_field::type_id::create("cpol");
    cpha = uvm_reg_field::type_id::create("cpha");
    rsvd = uvm_reg_field::type_id::create("rsvd");
    en.configure  (this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
    cpol.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
    cpha.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
    rsvd.configure(this, 5, 3, "RO", 0, 5'h0, 1, 1, 0);
  endfunction

endclass : spi_ctrl_reg

// ---- 0x04 DIVIDER ----
class spi_divider_reg extends uvm_reg;

  rand uvm_reg_field div;     // [7:0] 分频（半周期 = div 个系统时钟）

  `uvm_object_utils(spi_divider_reg)

  function new(string name = "spi_divider_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    div = uvm_reg_field::type_id::create("div");
    div.configure(this, 8, 0, "RW", 0, 8'd8, 1, 1, 0);   // 复位值与 DUT 一致 = 8
  endfunction

endclass : spi_divider_reg

// ---- 0x08 TX_DATA ----
class spi_tx_reg extends uvm_reg;

  rand uvm_reg_field tx;      // [7:0] 写启动传输

  `uvm_object_utils(spi_tx_reg)

  function new(string name = "spi_tx_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    tx = uvm_reg_field::type_id::create("tx");
    tx.configure(this, 8, 0, "RW", 0, 8'h00, 1, 1, 0);
  endfunction

endclass : spi_tx_reg

// ---- 0x0C RX_DATA ----
class spi_rx_reg extends uvm_reg;

  rand uvm_reg_field rx;      // [7:0] 接收数据（只读）

  `uvm_object_utils(spi_rx_reg)

  function new(string name = "spi_rx_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    rx = uvm_reg_field::type_id::create("rx");
    rx.configure(this, 8, 0, "RO", 0, 8'h00, 1, 1, 0);
  endfunction

endclass : spi_rx_reg

// ---- 0x10 STATUS ----
class spi_status_reg extends uvm_reg;

  rand uvm_reg_field busy;     // [0] 传输中
  rand uvm_reg_field rx_valid; // [1] RX_DATA 有效
  rand uvm_reg_field rsvd;     // [7:2]

  `uvm_object_utils(spi_status_reg)

  function new(string name = "spi_status_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    busy     = uvm_reg_field::type_id::create("busy");
    rx_valid = uvm_reg_field::type_id::create("rx_valid");
    rsvd     = uvm_reg_field::type_id::create("rsvd");
    busy.configure    (this, 1, 0, "RO", 0, 1'b0, 1, 1, 0);
    rx_valid.configure(this, 1, 1, "RO", 0, 1'b0, 1, 1, 0);
    rsvd.configure    (this, 6, 2, "RO", 0, 6'h0, 1, 1, 0);
  endfunction

endclass : spi_status_reg

// ---- 寄存器块 ----
class spi_reg_block extends uvm_reg_block;

  `uvm_object_utils(spi_reg_block)

  rand spi_ctrl_reg    ctrl;
  rand spi_divider_reg divider;
  rand spi_tx_reg      tx_data;
  rand spi_rx_reg      rx_data;
  rand spi_status_reg  status;

  function new(string name = "spi_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    ctrl    = spi_ctrl_reg::type_id::create("ctrl");
    divider = spi_divider_reg::type_id::create("divider");
    tx_data = spi_tx_reg::type_id::create("tx_data");
    rx_data = spi_rx_reg::type_id::create("rx_data");
    status  = spi_status_reg::type_id::create("status");

    // 注意：configure() 只是把寄存器挂到 block 上，
    // 必须再显式调用 build() 才会创建/配置内部的 uvm_reg_field
    ctrl.configure(this);
    ctrl.build();
    divider.configure(this);
    divider.build();
    tx_data.configure(this);
    tx_data.build();
    rx_data.configure(this);
    rx_data.build();
    status.configure(this);
    status.build();

    default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);
    default_map.add_reg(ctrl,    8'h00, "RW");
    default_map.add_reg(divider, 8'h04, "RW");
    default_map.add_reg(tx_data, 8'h08, "RW");
    default_map.add_reg(rx_data, 8'h0C, "RO");
    default_map.add_reg(status,  8'h10, "RO");

    lock_model();
  endfunction

endclass : spi_reg_block
