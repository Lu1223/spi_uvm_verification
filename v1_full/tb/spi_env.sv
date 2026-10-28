// ============================================================================
// spi_env.sv —— 验证环境顶层
// 组件清单：
//   寄存器侧：reg_agent（driver/monitor/sequencer）+ RAL（regmodel+adapter+predictor）
//   SPI 侧  ：slave_drv + slave_sqr（slave 模型）、spi_mon（总线观测）
//   分析侧  ：scb（计分板）、cov（功能覆盖率）
//
// connect_phase 数据流：
//   reg_agent.monitor.ap ──> predictor.bus_in   （更新 RAL 镜像）
//                         ──> scb.reg_imp       （跟踪状态/收集读回）
//                         ──> cov.analysis_export（功能覆盖采样）
//   spi_mon.ap            ──> scb.spi_imp
//                         ──> cov.spi_imp
//   slave_drv.slave_byte_ap ─> scb.slave_imp
// ============================================================================
class spi_env extends uvm_env;

  `uvm_component_utils(spi_env)

  // ---- 寄存器侧 ----
  spi_reg_agent       reg_agent;
  spi_reg_block       regmodel;
  spi_reg_adapter     adapter;
  uvm_reg_predictor #(spi_reg_item) predictor;

  // ---- SPI 侧 ----
  spi_slave_driver    slave_drv;
  spi_slave_sequencer slave_sqr;
  spi_bus_monitor     spi_mon;

  // ---- 分析侧 ----
  spi_scoreboard      scb;
  spi_cov_collector   cov;

  function new(string name = "spi_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    reg_agent = spi_reg_agent::type_id::create("reg_agent", this);

    regmodel  = spi_reg_block::type_id::create("regmodel", this);
    regmodel.build();
    adapter   = spi_reg_adapter::type_id::create("adapter", this);
    predictor = uvm_reg_predictor #(spi_reg_item)::type_id::create("predictor", this);

    slave_drv = spi_slave_driver::type_id::create("slave_drv", this);
    slave_sqr = spi_slave_sequencer::type_id::create("slave_sqr", this);
    spi_mon   = spi_bus_monitor::type_id::create("spi_mon", this);

    scb = spi_scoreboard::type_id::create("scb", this);
    cov = spi_cov_collector::type_id::create("cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // RAL：把 adapter 挂到 reg sequencer 上；关闭自动预测，改用显式 predictor
    regmodel.default_map.set_sequencer(reg_agent.sequencer, adapter);
    regmodel.default_map.set_auto_predict(0);
    predictor.map     = regmodel.default_map;
    predictor.adapter = adapter;

    // 寄存器观测 → predictor / scoreboard / coverage
    reg_agent.monitor.ap.connect(predictor.bus_in);
    reg_agent.monitor.ap.connect(scb.reg_imp);
    reg_agent.monitor.ap.connect(cov.analysis_export);

    // SPI 观测 → scoreboard / coverage
    spi_mon.ap.connect(scb.spi_imp);
    spi_mon.ap.connect(cov.spi_imp);

    // slave 自报字节 → scoreboard
    slave_drv.slave_byte_ap.connect(scb.slave_imp);

    // slave driver 与 sequencer 相连
    slave_drv.seq_item_port.connect(slave_sqr.seq_item_export);
  endfunction

endclass : spi_env
