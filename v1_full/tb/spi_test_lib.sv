// ============================================================================
// spi_test_lib.sv —— 测试用例库
//   1. spi_smoke_test  ：冒烟测试——最小闭环跑通一次传输
//   2. spi_mode_test   ：四种 CPOL/CPHA 模式 × 典型数据
//   3. spi_rand_test   ：随机回归——随机模式/分频/数据/次数
//   4. spi_corner_test ：边界与异常——极值分频、边界数据、en=0、忙时写、rx_valid 清零
// ============================================================================

// ================= 1. 冒烟测试：最小闭环 =================
class spi_smoke_test extends spi_base_test;

  `uvm_component_utils(spi_smoke_test)

  function new(string name = "spi_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task do_main();
    uvm_status_e   st;
    uvm_reg_data_t val;
    bit [7:0]      rx;

    // 复位初值检查（DUT 复位值应与 RAL 复位值一致）
    env.regmodel.ctrl.read(st, val);
    if (val[7:0] !== 8'h00) `uvm_error("T", $sformatf("复位后 CTRL=%h 期望=00", val[7:0]))
    env.regmodel.status.read(st, val);
    if (val[7:0] !== 8'h00) `uvm_error("T", $sformatf("复位后 STATUS=%h 期望=00", val[7:0]))

    // 配置：使能、模式 0（CPOL=0/CPHA=0）、分频 8
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd8);

    // 一次传输：master 发 A5，slave 回送 5A
    do_transfer(8'hA5, 8'h5A, rx);
    if (rx !== 8'h5A)
      `uvm_error("T", $sformatf("SMOKE FAIL: rx=%h 期望=5A", rx))
    else
      `uvm_info("T", "SMOKE PASS: tx=A5 -> rx=5A", UVM_MEDIUM)
  endtask

endclass : spi_smoke_test

// ================= 2. 四种 SPI 模式测试 =================
class spi_mode_test extends spi_base_test;

  `uvm_component_utils(spi_mode_test)

  function new(string name = "spi_mode_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task do_main();
    bit [7:0] rx;
    bit [7:0] data_q[3] = '{8'h5A, 8'h00, 8'hFF};

    for (int cpol = 0; cpol <= 1; cpol++) begin
      for (int cpha = 0; cpha <= 1; cpha++) begin
        cfg_mode(1'b1, cpol[0], cpha[0], 8'd8);
        foreach (data_q[j]) begin
          do_transfer(data_q[j], ~data_q[j], rx);
          if (rx !== ~data_q[j])
            `uvm_error("T", $sformatf("MODE cpol=%0d cpha=%0d FAIL: tx=%h rx=%h",
                       cpol, cpha, data_q[j], rx))
          else
            `uvm_info("T", $sformatf("MODE cpol=%0d cpha=%0d PASS: tx=%h rx=%h",
                       cpol, cpha, data_q[j], rx), UVM_MEDIUM)
        end
      end
    end
  endtask

endclass : spi_mode_test

// ================= 3. 随机回归测试 =================
class spi_rand_test extends spi_base_test;

  `uvm_component_utils(spi_rand_test)

  rand bit           cpol, cpha;
  rand bit [7:0]     div;
  rand int unsigned  n_tx;
  rand bit [7:0]     data_q[$];

  constraint c_div  { div inside {[8'd2:8'd64]}; }
  constraint c_n    { n_tx inside {[4:12]}; }
  constraint c_data { data_q.size() == n_tx; }

  function new(string name = "spi_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task do_main();
    bit [7:0] rx;
    void'(this.randomize());
    `uvm_info("T", $sformatf("随机参数: cpol=%0b cpha=%0b div=%0d n_tx=%0d", cpol, cpha, div, n_tx), UVM_MEDIUM)

    cfg_mode(1'b1, cpol, cpha, div);
    foreach (data_q[i]) begin
      do_transfer(data_q[i], ~data_q[i], rx);
      if (rx !== ~data_q[i])
        `uvm_error("T", $sformatf("RAND [%0d] FAIL: tx=%h rx=%h", i, data_q[i], rx))
    end
    `uvm_info("T", $sformatf("RAND PASS: %0d 次随机传输全部正确", n_tx), UVM_MEDIUM)
  endtask

endclass : spi_rand_test

// ================= 4. 边界与异常测试 =================
class spi_corner_test extends spi_base_test;

  `uvm_component_utils(spi_corner_test)

  function new(string name = "spi_corner_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task do_main();
    uvm_status_e   st;
    uvm_reg_data_t val;
    bit [7:0]      rx;
    spi_exp_trans  exp;

    // ---- C1: 复位后 RX_DATA 初值为 0 ----
    env.regmodel.rx_data.read(st, val);
    if (val[7:0] !== 8'h00) `uvm_error("T", $sformatf("C1 FAIL: rx_data 初值=%h 期望=00", val[7:0]))

    // ---- C2: 最小分频 div=2，全 1 数据 ----
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd2);
    do_transfer(8'hFF, 8'h00, rx);
    if (rx !== 8'h00) `uvm_error("T", $sformatf("C2 FAIL: rx=%h 期望=00", rx))

    // ---- C3: 最大分频 div=255，交替数据 ----
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd255);
    do_transfer(8'hAA, 8'h55, rx);
    if (rx !== 8'h55) `uvm_error("T", $sformatf("C3 FAIL: rx=%h 期望=55", rx))

    // ---- C4: en=0 时写 TX_DATA 应被忽略（无传输发生、tx_data 不变） ----
    // 注意：此时 rx_valid 仍为 C3 传输留下的 1（新传输启动才会清零），
    // 检查重点是 busy=0、cs_n 保持高、tx_data 未被改写
    cfg_mode(1'b0, 1'b0, 1'b0, 8'd8);
    env.regmodel.tx_data.write(st, 8'h5A);
    #3000ns;
    env.regmodel.status.read(st, val);
    if (val[0] !== 1'b0) `uvm_error("T", $sformatf("C4 FAIL: en=0 时 busy 应为 0 (status=%h)", val[7:0]))
    if (val[1] !== 1'b1) `uvm_error("T", $sformatf("C4 FAIL: rx_valid 应保持 C3 的 1 (status=%h)", val[7:0]))
    if (vif.spi_cs_n !== 1'b1) `uvm_error("T", "C4 FAIL: en=0 时 cs_n 应保持高")
    env.regmodel.tx_data.read(st, val);
    if (val[7:0] !== 8'hAA) `uvm_error("T", $sformatf("C4 FAIL: 被忽略的写不应改 tx_data (=%h, 应为 C3 的 AA)", val[7:0]))

    // ---- C5: 忙时写 TX_DATA 被忽略，传输完成后状态正常 ----
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd200);
    begin
      exp = spi_exp_trans::type_id::create("exp");
      exp.tx_byte    = 8'h11;
      exp.slave_byte = 8'hEE;
      env.scb.push_exp(exp);
      start_slave(8'hEE, 1);

      env.regmodel.tx_data.write(st, 8'h11);   // 启动传输（div=200，传输约 32us）
      #1000ns;                                  // 此刻 busy=1
      env.regmodel.tx_data.write(st, 8'h22);   // 忙时写 → 应被忽略
      repeat (10000) begin
        env.regmodel.status.read(st, val);
        if (val[1]) break;
        #500ns;
      end
      env.regmodel.rx_data.read(st, val);
      if (val[7:0] !== 8'hEE) `uvm_error("T", $sformatf("C5 FAIL: rx=%h 期望=EE（应为第一次传输结果）", val[7:0]))
      #5000ns;                                  // 若 tx2 未被忽略，这里会多一次传输
      env.regmodel.status.read(st, val);
      // 期望：rx_valid=1（第一次传输的结果仍有效）、busy=0（无第二次传输）
      if (val[1:0] !== 2'b10) `uvm_error("T", $sformatf("C5 FAIL: 忙时写未正确忽略 (status=%h)", val[7:0]))
    end

    // ---- C6: 新传输启动时 rx_valid 应立即清零 ----
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd8);
    do_transfer(8'h33, 8'hCC, rx);
    if (rx !== 8'hCC) `uvm_error("T", $sformatf("C6 FAIL: 第一次传输 rx=%h", rx))
    begin
      exp = spi_exp_trans::type_id::create("exp");
      exp.tx_byte    = 8'h44;
      exp.slave_byte = 8'hBB;
      env.scb.push_exp(exp);
      start_slave(8'hBB, 1);

      env.regmodel.tx_data.write(st, 8'h44);   // 启动第二次传输
      env.regmodel.status.read(st, val);       // 立即读状态
      if (val[1] !== 1'b0) `uvm_error("T", $sformatf("C6 FAIL: 新传输启动后 rx_valid 未清零 (status=%h)", val[7:0]))
      repeat (10000) begin
        env.regmodel.status.read(st, val);
        if (val[1]) break;
        #500ns;
      end
      env.regmodel.rx_data.read(st, val);
      if (val[7:0] !== 8'hBB) `uvm_error("T", $sformatf("C6 FAIL: 第二次传输 rx=%h 期望=BB", val[7:0]))
    end

    // ---- C7: 分频钳位（写 1 → 钳到 2）+ 读回 DIVIDER ----
    // 覆盖率分析补充：此前从未读 DIVIDER、从未触发 <2 钳位分支
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd1);
    env.regmodel.divider.read(st, val);
    if (val[7:0] !== 8'd2) `uvm_error("T", $sformatf("C7 FAIL: div 写 1 应钳到 2 (=%h)", val[7:0]))
    do_transfer(8'h5A, 8'hA5, rx);       // 用钳位后的 div=2 跑一次传输
    if (rx !== 8'hA5) `uvm_error("T", $sformatf("C7 FAIL: rx=%h 期望=A5", rx))

    // ---- C8: 非法地址访问（读写都应无副作用，读返回 0） ----
    // 覆盖率分析补充：总线读写 case 的 default 分支此前从未命中
    // RAL 只能访问已建模寄存器，非法地址需用原始序列往 reg sequencer 发总线 item
    begin
      spi_reg_item   item;
      spi_reg_raw_seq raw;
      // 非法地址写
      item = spi_reg_item::type_id::create("item");
      item.addr = 8'h20;
      item.data = 32'h1234_5678;
      item.kind = SPI_WRITE;
      raw = spi_reg_raw_seq::type_id::create("raw");
      raw.item = item;
      raw.start(env.reg_agent.sequencer);
      // 非法地址读 → 应返回 0
      item = spi_reg_item::type_id::create("item");
      item.addr = 8'h20;
      item.kind = SPI_READ;
      raw = spi_reg_raw_seq::type_id::create("raw");
      raw.item = item;
      raw.start(env.reg_agent.sequencer);
      if (item.data !== 32'h0) `uvm_error("T", $sformatf("C8 FAIL: 非法地址读应返回 0 (=%h)", item.data))
      // 写只读寄存器 RX_DATA → 应被忽略
      item = spi_reg_item::type_id::create("item");
      item.addr = 8'h0C;
      item.data = 32'hDEAD_BEEF;
      item.kind = SPI_WRITE;
      raw = spi_reg_raw_seq::type_id::create("raw");
      raw.item = item;
      raw.start(env.reg_agent.sequencer);
      env.regmodel.rx_data.read(st, val);
      if (val[7:0] !== 8'hA5) `uvm_error("T", $sformatf("C8 FAIL: 写 RO 寄存器应无效 (rx_data=%h)", val[7:0]))
    end

    // ---- C9: div=16（覆盖 div_mid 分桶）+ walking-one 数据（提升 toggle） ----
    // 覆盖率分析补充：div_cg 的 [9:32] 桶未命中；数据位 0/1 翻转不充分
    cfg_mode(1'b1, 1'b0, 1'b0, 8'd16);
    begin
      bit [7:0] walk_q[8] = '{8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80};
      foreach (walk_q[i]) begin
        do_transfer(walk_q[i], ~walk_q[i], rx);
        if (rx !== ~walk_q[i])
          `uvm_error("T", $sformatf("C9 FAIL: walk[%0d] tx=%h rx=%h", i, walk_q[i], rx))
      end
    end

    `uvm_info("T", "CORNER: 边界与异常场景执行完毕", UVM_MEDIUM)
  endtask

endclass : spi_corner_test
