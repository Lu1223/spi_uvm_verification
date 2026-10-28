// ============================================================================
// spi_base_test.sv —— 测试基类
// 提供公共工具：
//   cfg_mode()   —— 配置使能/模式/分频（走 RAL）
//   do_transfer()—— 发起一次传输并等待完成（push 期望 + 后台 slave 序列 + RAL 读写）
// 子类在 do_main() 里编排自己的场景
// ============================================================================
class spi_base_test extends uvm_test;

  `uvm_component_utils(spi_base_test)

  spi_env env;
  virtual spi_if vif;

  function new(string name = "spi_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = spi_env::type_id::create("env", this);
    if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "spi_base_test: 未能从 config_db 获取 virtual spi_if")
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait (vif.rst_n === 1'b1);     // 等复位释放再开始
    do_main();
    phase.drop_objection(this);
  endtask

  // 子类在这里写自己的测试场景
  virtual task do_main();
    `uvm_info("T", "spi_base_test 空场景（不应直接运行）", UVM_MEDIUM)
  endtask

  // ================= 工具任务 =================

  // 当前模式（cfg_mode 时更新，供 slave 序列携带）
  bit cur_cpol;
  bit cur_cpha;

  // 配置 SPI 工作参数（走 RAL 前门访问），并通知 SPI monitor 当前模式
  virtual task cfg_mode(bit en_, bit cpol_, bit cpha_, bit [7:0] div);
    uvm_status_e st;
    env.regmodel.ctrl.write(st, {5'h0, cpha_, cpol_, en_});
    env.regmodel.divider.write(st, div);
    cur_cpol = cpol_;
    cur_cpha = cpha_;
    env.spi_mon.set_mode(cpol_, cpha_);
  endtask

  // 后台启动 slave 序列：在接下来的 count 次传输中回送 data
  function void start_slave(bit [7:0] data, int unsigned count);
    spi_slave_seq s;
    s = spi_slave_seq::type_id::create("s");
    s.data  = data;
    s.count = count;
    s.cpol  = cur_cpol;
    s.cpha  = cur_cpha;
    fork
      s.start(env.slave_sqr);
    join_none
  endfunction

  // 发起一次传输并等待完成：
  //   tx         —— 写入 TX_DATA 的字节（master 发出）
  //   slave_byte —— slave 模型在 MISO 上回送的字节
  //   rx         —— DUT 收到的字节（读 RX_DATA 得到）
  virtual task do_transfer(bit [7:0] tx, bit [7:0] slave_byte, output bit [7:0] rx);
    uvm_status_e   st;
    uvm_reg_data_t val;
    spi_exp_trans  exp;

    // 1. 先把期望推给 scoreboard（只有确定会被 DUT 接受的传输才推送）
    exp = spi_exp_trans::type_id::create("exp");
    exp.tx_byte    = tx;
    exp.slave_byte = slave_byte;
    env.scb.push_exp(exp);

    // 2. 后台启动 slave 序列：准备好回送字节
    start_slave(slave_byte, 1);

    // 3. 写 TX_DATA 启动传输
    env.regmodel.tx_data.write(st, tx);

    // 4. 轮询 STATUS 直到 rx_valid
    repeat (10000) begin
      env.regmodel.status.read(st, val);
      if (val[1]) break;
      #500ns;
    end
    if (!val[1])
      `uvm_error("T", $sformatf("rx_valid 超时未置位 (tx=%h)", tx))

    // 5. 读回 RX_DATA，并校验 RAL 镜像同步
    env.regmodel.rx_data.read(st, val);
    rx = val[7:0];
    // 注意：本环境 auto_predict=0，镜像由 monitor→predictor 异步更新，
    // 读操作返回后要等一拍让 predictor 处理完总线观测再查镜像
    #1000ns;
    if (env.regmodel.rx_data.get_mirrored_value() !== rx)
      `uvm_error("T", $sformatf("RAL 镜像与读回不一致: mirror=%h rx=%h",
                 env.regmodel.rx_data.get_mirrored_value(), rx))
  endtask

endclass : spi_base_test
