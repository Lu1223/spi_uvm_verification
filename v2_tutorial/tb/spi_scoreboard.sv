// ============================================================================
// spi_scoreboard.sv —— 计分板（骨架文件）
// 【对应指导文档】docs/08_spi_scoreboard计分板.md
// 【你要写的】三个观测 imp + 期望队列 + check_phase 比对
//
// 比对设计（check_phase 统一执行）：
//   ① mosi_q[i]  == exp_q[i].tx_byte    DUT 发对了
//   ② slave_q[i] == exp_q[i].slave_byte slave 模型发对了
//   ③ miso_q[i]  == slave_q[i]          总线观测与 slave 自报一致
//   ④ rx_q[i]    == miso_q[i]           DUT 收对了
//   ⑤ 五组队列数量一致                   无多余/丢失传输
// ============================================================================
class spi_scoreboard extends uvm_scoreboard;

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：三个 imp（宏在 pkg 里声明过）：
  //   uvm_analysis_imp_reg   #(spi_reg_item,   spi_scoreboard) reg_imp;
  //   uvm_analysis_imp_spi   #(spi_bus_trans,  spi_scoreboard) spi_imp;
  //   uvm_analysis_imp_slave #(spi_slave_item, spi_scoreboard) slave_imp;
  // TODO 3：参考模型队列：
  //   spi_exp_trans exp_q[$];  bit[7:0] mosi_q[$], miso_q[$], slave_q[$], rx_q[$];
  //   bit rx_valid_seen;
  // TODO 4：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 5：super.build_phase(phase); 三个 imp 用 new("xx_imp", this) 创建
  endfunction

  // TODO 6：push_exp(spi_exp_trans exp) —— test 发起传输前推期望（普通函数即可）

  // TODO 7：write_reg(spi_reg_item item)（reg_imp 回调）：
  //   读 STATUS(0x10)：rx_valid_seen = item.data[1];
  //   读 RX_DATA(0x0C) 且 rx_valid_seen==1：rx_q.push_back(item.data[7:0]);
  //     rx_valid_seen = 1'b0;    // 一次有效读回只记录一次
  //   ★ 为什么加 rx_valid_seen 条件？复位后初值检查也会读 RX_DATA，
  //     那不是传输结果，必须过滤掉

  // TODO 8：write_spi(spi_bus_trans tr)：mosi_q/miso_q push

  // TODO 9：write_slave(spi_slave_item item)：slave_q push

  virtual function void check_phase(uvm_phase phase);
    // TODO 10：super.check_phase(phase);
    // TODO 11：先查五组队列数量一致，不一致 `uvm_error + return
    // TODO 12：foreach (exp_q[i]) 做 ①~④ 四项比对，不一致 `uvm_error
    // TODO 13：全对时 `uvm_info("SCB", "...n 次传输全部比对一致", UVM_MEDIUM)
  endfunction

endclass : spi_scoreboard
