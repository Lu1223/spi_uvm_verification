// ============================================================================
// spi_scoreboard.sv —— 计分板
// 三个观测输入：
//   1. reg_imp   ：寄存器总线观测（跟踪 STATUS.rx_valid、收集 RX_DATA 读回值）
//   2. spi_imp   ：SPI 总线观测（master 发出的 mosi 字节 + slave 发出的 miso 字节）
//   3. slave_imp ：slave 模型自报实际发送的字节
// 期望输入：
//   test 在发起传输前调用 push_exp() 推送期望（只有确定被 DUT 接受的传输才推）
//
// 比对项（check_phase 统一执行）：
//   ① MOSI 观测 == 期望 tx_byte      （DUT 发对了数据）
//   ② slave 自报 == 期望 slave_byte  （slave 模型发对了数据）
//   ③ MISO 观测 == slave 自报        （总线观测与模型一致）
//   ④ RX_DATA 读回 == MISO           （DUT 收对了 slave 发的数据）
//   ⑤ 四组数量一致                    （没有多余/丢失的传输）
// ============================================================================
class spi_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(spi_scoreboard)

  // ---- 三个观测输入 imp ----
  uvm_analysis_imp_reg   #(spi_reg_item,   spi_scoreboard) reg_imp;
  uvm_analysis_imp_spi   #(spi_bus_trans,  spi_scoreboard) spi_imp;
  uvm_analysis_imp_slave #(spi_slave_item, spi_scoreboard) slave_imp;

  // ---- 参考模型队列 ----
  spi_exp_trans exp_q[$];    // 期望（test 推送）
  bit [7:0] mosi_q[$];       // 实测 master 字节
  bit [7:0] miso_q[$];       // 实测 slave 字节
  bit [7:0] slave_q[$];      // slave 模型自报字节
  bit [7:0] rx_q[$];         // DUT RX_DATA 读回值

  bit rx_valid_seen;         // 依据 STATUS 读观测 rx_valid 当前状态

  function new(string name = "spi_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_imp   = new("reg_imp",   this);
    spi_imp   = new("spi_imp",   this);
    slave_imp = new("slave_imp", this);
  endfunction

  // ---- test 在发起传输前推送期望 ----
  function void push_exp(spi_exp_trans exp);
    exp_q.push_back(exp);
  endfunction

  // ---- 寄存器总线观测 ----
  virtual function void write_reg(spi_reg_item item);
    if (item.kind == SPI_READ && item.addr == 8'h10) begin
      rx_valid_seen = item.data[1];              // 跟踪 STATUS.rx_valid
    end
    else if (item.kind == SPI_READ && item.addr == 8'h0C && rx_valid_seen) begin
      rx_q.push_back(item.data[7:0]);            // rx_valid 有效时的 RX_DATA 读回才记录
      rx_valid_seen = 1'b0;                      // 一次有效读回只记录一次
    end
  endfunction

  // ---- SPI 总线观测 ----
  virtual function void write_spi(spi_bus_trans tr);
    mosi_q.push_back(tr.mosi_byte);
    miso_q.push_back(tr.miso_byte);
  endfunction

  // ---- slave 模型自报 ----
  virtual function void write_slave(spi_slave_item item);
    slave_q.push_back(item.data);
  endfunction

  // ---- 仿真结束统一比对 ----
  virtual function void check_phase(uvm_phase phase);
    int errors = 0;
    super.check_phase(phase);

    if (!(exp_q.size() == mosi_q.size() && mosi_q.size() == miso_q.size() &&
          miso_q.size() == slave_q.size() && slave_q.size() == rx_q.size())) begin
      `uvm_error("SCB", $sformatf("数量不一致: exp=%0d mosi=%0d miso=%0d slave=%0d rx=%0d",
                 exp_q.size(), mosi_q.size(), miso_q.size(), slave_q.size(), rx_q.size()))
      return;
    end

    foreach (exp_q[i]) begin
      // ① DUT 发出的 MOSI == 写入 TX_DATA 的值
      if (mosi_q[i] !== exp_q[i].tx_byte) begin
        `uvm_error("SCB", $sformatf("[%0d] MOSI=%h 期望tx=%h", i, mosi_q[i], exp_q[i].tx_byte))
        errors++;
      end
      // ② slave 实际发出 == 期望 slave 字节
      if (slave_q[i] !== exp_q[i].slave_byte) begin
        `uvm_error("SCB", $sformatf("[%0d] slave=%h 期望=%h", i, slave_q[i], exp_q[i].slave_byte))
        errors++;
      end
      // ③ MISO 上观测 == slave 实际发出
      if (miso_q[i] !== slave_q[i]) begin
        `uvm_error("SCB", $sformatf("[%0d] MISO=%h slave=%h", i, miso_q[i], slave_q[i]))
        errors++;
      end
      // ④ DUT RX_DATA 读回 == MISO（DUT 收对了）
      if (rx_q[i] !== miso_q[i]) begin
        `uvm_error("SCB", $sformatf("[%0d] RX=%h MISO=%h", i, rx_q[i], miso_q[i]))
        errors++;
      end
    end

    if (errors == 0)
      `uvm_info("SCB", $sformatf("SCOREBOARD PASS: %0d 次传输全部比对一致", exp_q.size()), UVM_MEDIUM)
  endfunction

endclass : spi_scoreboard
