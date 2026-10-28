// ============================================================================
// spi_reg_block.sv —— RAL 寄存器模型（骨架文件）
// 【对应指导文档】docs/06_寄存器模型RAL.md
// 【你要写的】5 个寄存器类（字段建模）+ 寄存器块（挂寄存器/建 map/加地址）
//
// 寄存器表（与 DUT 一致）：
//   0x00 CTRL    : en[0] RW / cpol[1] RW / cpha[2] RW / rsvd[7:3] RO  复位 0
//   0x04 DIVIDER : div[7:0] RW                                         复位 8
//   0x08 TX_DATA : tx[7:0] RW                                          复位 0
//   0x0C RX_DATA : rx[7:0] RO                                          复位 0
//   0x10 STATUS  : busy[0] RO / rx_valid[1] RO / rsvd[7:2] RO          复位 0
// ============================================================================

// TODO 1：写 5 个寄存器类（每个都是 uvm_reg 子类，8 bit 宽）：
//   spi_ctrl_reg / spi_divider_reg / spi_tx_reg / spi_rx_reg / spi_status_reg
//   每个类模式相同：
//     class spi_ctrl_reg extends uvm_reg;
//       rand uvm_reg_field en, cpol, cpha, rsvd;
//       `uvm_object_utils(spi_ctrl_reg)
//       function new(string name = "spi_ctrl_reg");
//         super.new(name, 8, UVM_NO_COVERAGE);   // 宽度 8 bit
//       endfunction
//       virtual function void build();
//         en = uvm_reg_field::type_id::create("en");
//         ...
//         en.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
//         // 参数：parent, 位宽, lsb, 访问属性, volatile, 复位值, has_reset, is_rand, individually_accessible
//       endfunction
//     endclass

// TODO 2：写寄存器块 spi_reg_block extends uvm_reg_block：
//   build() 里：
//     ctrl    = spi_ctrl_reg::type_id::create("ctrl");
//     ctrl.configure(this);
//     ctrl.build();          // ★★★★★ 千万别漏！漏了 field 不创建，
//                            // 读写能工作但镜像永远不更新（v1 踩过的坑）
//     ...（每个寄存器都这样）
//     default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);
//     default_map.add_reg(ctrl,    8'h00, "RW");
//     default_map.add_reg(divider, 8'h04, "RW");
//     default_map.add_reg(tx_data, 8'h08, "RW");
//     default_map.add_reg(rx_data, 8'h0C, "RO");
//     default_map.add_reg(status,  8'h10, "RO");
//     lock_model();
