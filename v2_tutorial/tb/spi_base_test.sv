// ============================================================================
// spi_base_test.sv —— 测试基类（骨架文件）
// 【对应指导文档】docs/11_test与tb_top.md
// 【你要写的】env 创建 + 三个工具任务（cfg_mode / start_slave / do_transfer）
// ============================================================================
class spi_base_test extends uvm_test;

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：spi_env env;  virtual spi_if vif;
  // TODO 3：bit cur_cpol, cur_cpha;   // 当前模式（cfg_mode 时更新）
  // TODO 4：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 5：super.build_phase(phase);
    // TODO 6：env = spi_env::type_id::create("env", this);
    // TODO 7：config_db 取 vif
  endfunction

  virtual task run_phase(uvm_phase phase);
    // TODO 8：phase.raise_objection(this);
    // TODO 9：wait (vif.rst_n === 1'b1);   // 等复位释放
    // TODO 10：do_main();
    // TODO 11：phase.drop_objection(this);
  endtask

  // TODO 12：virtual task do_main(); 空实现（子类覆盖）

  // TODO 13：cfg_mode(en, cpol, cpha, div)：
  //   RAL 写 ctrl = {5'h0, cpha, cpol, en}；写 divider = div
  //   保存 cur_cpol/cur_cpha；调 env.spi_mon.set_mode(cpol, cpha)

  // TODO 14：start_slave(data, count)：
  //   创建 spi_slave_seq，填 data/count/cpol/cpha，fork start(env.slave_sqr) join_none

  // TODO 15：do_transfer(tx, slave_byte, output rx)：
  //   1) 创建 spi_exp_trans{tx_byte=tx, slave_byte} → env.scb.push_exp(exp)
  //   2) start_slave(slave_byte, 1)
  //   3) env.regmodel.tx_data.write(st, tx);        // 启动传输
  //   4) repeat(10000)：读 status，val[1]（rx_valid）为 1 就 break，#500ns
  //      超时 `uvm_error
  //   5) env.regmodel.rx_data.read(st, val); rx = val[7:0];
  //      #1000ns;   ← 等 predictor 异步更新镜像！
  //      if (env.regmodel.rx_data.get_mirrored_value() !== rx) `uvm_error
  //   ★ 镜像检查为什么加 #1000ns？auto_predict=0 时镜像由
  //     monitor→predictor 异步更新，读返回后要等一拍

endclass : spi_base_test
