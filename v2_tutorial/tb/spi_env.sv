// ============================================================================
// spi_env.sv —— 环境顶层（骨架文件）
// 【对应指导文档】docs/10_spi_env环境集成.md
// 【你要写的】创建全部组件 + connect_phase 连线
//
// 组件清单：
//   寄存器侧：reg_agent + regmodel(RAL) + adapter + predictor
//   SPI 侧  ：slave_drv + slave_sqr + spi_mon
//   分析侧  ：scb + cov
//
// connect_phase 数据流：
//   reg_agent.monitor.ap ──> predictor.bus_in（更新 RAL 镜像）
//                         ──> scb.reg_imp
//                         ──> cov.analysis_export
//   spi_mon.ap            ──> scb.spi_imp
//                         ──> cov.spi_imp
//   slave_drv.slave_byte_ap ─> scb.slave_imp
// ============================================================================
class spi_env extends uvm_env;

  // TODO 1：`uvm_component_utils 注册
  // TODO 2：声明成员（见上面清单；predictor 类型是
  //         uvm_reg_predictor #(spi_reg_item)）
  // TODO 3：new()

  virtual function void build_phase(uvm_phase phase);
    // TODO 4：super.build_phase(phase);
    // TODO 5：type_id::create 创建全部组件
    // TODO 6：regmodel.build();   ← RAL 寄存器块必须显式 build！
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    // TODO 7：super.connect_phase(phase);
    // TODO 8：RAL 三件套：
    //   regmodel.default_map.set_sequencer(reg_agent.sequencer, adapter);
    //   regmodel.default_map.set_auto_predict(0);
    //   predictor.map     = regmodel.default_map;
    //   predictor.adapter = adapter;
    // TODO 9：按上面数据流图 connect 各 analysis port
    // TODO 10：slave_drv.seq_item_port.connect(slave_sqr.seq_item_export);
    //          ★★★ 千万别漏！漏了 slave driver 会空指针崩溃
  endfunction

endclass : spi_env
