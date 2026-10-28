// ============================================================================
// spi_test_lib.sv —— 测试用例库（骨架文件）
// 【对应指导文档】docs/11_test与tb_top.md
// 【你要写的】4 个测试：
//   1. spi_smoke_test  ：复位检查 + 模式0 单次传输（先跑通它！）
//   2. spi_mode_test   ：4 模式 × {5A,00,FF}（slave 回送 ~tx）
//   3. spi_rand_test   ：随机模式/分频[2:64]/数据/次数[4:12]
//   4. spi_corner_test ：C1~C9 边界与异常
// ============================================================================

// TODO 1：spi_smoke_test（继承 spi_base_test，覆盖 do_main）：
//   复位后读 ctrl/status 应为 0
//   cfg_mode(1, 0, 0, 8)
//   do_transfer(8'hA5, 8'h5A, rx);   // slave 回送 5A
//   rx != 8'h5A → `uvm_error；相等 → `uvm_info("SMOKE PASS...", UVM_MEDIUM)

// TODO 2：spi_mode_test：
//   双重循环 cpol 0/1 × cpha 0/1：
//     cfg_mode(1, cpol, cpha, 8)
//     数据队列 {5A, 00, FF} 逐个 do_transfer(data, ~data, rx)，比对 rx == ~data

// TODO 3：spi_rand_test（带 rand 字段的 test）：
//   rand bit cpol, cpha; rand bit[7:0] div; rand int n_tx; rand bit[7:0] data_q[$];
//   constraint：div in [2:64]、n_tx in [4:12]、data_q.size() == n_tx
//   do_main：void'(this.randomize()); cfg_mode; foreach 传输比对
//   ★ test 的 rand 字段不会自动随机化，必须手动 this.randomize()

// TODO 4：spi_corner_test（场景清单）：
//   C1 复位后 RX_DATA=0
//   C2 div=2 传输 FF（slave 回送 00）
//   C3 div=255 传输 AA（slave 回送 55）
//   C4 en=0 写 TX：等 3us 后 busy 应为 0、cs_n 保持高、tx_data 仍为 AA
//      （rx_valid 仍是 C3 留下的 1，别误判）
//   C5 忙时写：div=200 启动传输 1us 后写 TX 应被忽略；
//      完成后 rx==EE，再等 5us 状态应为 rx_valid=1 & busy=0（2'b10）
//   C6 新传输清零 rx_valid：连续两次传输，第二次启动后立即读 status，rx_valid 应为 0
//   C7 div 写 1 读回应为 2（钳位），再跑一次传输
//   C8 非法地址 0x20 写/读（读应返回 0）、写 RO 寄存器 0x0C 无效
//      （用 spi_reg_raw_seq + env.reg_agent.sequencer 发原始 item）
//   C9 div=16 + walking-one 8 字节 {01,02,04,08,10,20,40,80}

endclass_of_placeholder
