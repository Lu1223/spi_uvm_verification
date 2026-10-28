// ============================================================================
// spi_master.sv —— SPI Master DUT（待验证设计）
// ----------------------------------------------------------------------------
// 功能：
//   1. 简易同步寄存器总线（单周期读写，无等待）
//   2. SPI 主机：支持 CPOL/CPHA 四种模式、可配置分频、字节传输
//
// 寄存器映射：
//   0x00 CTRL    : [0] spi_en（1=使能） [1] cpol [2] cpha（其余保留，读 0）
//   0x04 DIVIDER : [7:0] clk_div（sclk 半周期 = clk_div 个系统时钟，写入 <2 按 2 处理）
//   0x08 TX_DATA : [7:0] 写该寄存器启动一次 8bit 传输
//                        （仅当 spi_en=1 且 busy=0 时写有效，否则忽略）
//   0x0C RX_DATA : [7:0] 只读，最近一次传输收到的字节
//   0x10 STATUS  : [0] busy（1=传输中） [1] rx_valid（1=RX_DATA 有效，新传输启动时清零）
//
// 总线协议（简易同步总线）：
//   bus_valid=1 当拍：bus_wr=1 表示写（下一拍 posedge 寄存）；bus_wr=0 表示读
//   （bus_rdata 组合逻辑当拍给出）；bus_ready 恒等于 bus_valid（无等待）
// ============================================================================
module spi_master (
  input  logic        clk,
  input  logic        rst_n,

  // ---- 简易同步寄存器总线 ----
  input  logic        bus_valid,
  input  logic [7:0]  bus_addr,
  input  logic [31:0] bus_wdata,
  input  logic        bus_wr,        // 1=写 0=读
  output logic        bus_ready,
  output logic [31:0] bus_rdata,

  // ---- SPI 引脚（本模块是 Master） ----
  output logic        spi_sclk,
  output logic        spi_cs_n,
  output logic        spi_mosi,
  input  logic        spi_miso
);

  // ================= 寄存器 =================
  logic        spi_en, cpol, cpha;
  logic [7:0]  clk_div;
  logic [7:0]  tx_data;
  logic [7:0]  rx_data;
  logic        busy, rx_valid;

  // 总线写译码：写 TX_DATA 且 DUT 当前能接收（en=1 且不忙）
  wire tx_wr      = bus_valid && bus_wr && (bus_addr == 8'h08);
  wire tx_accepted = tx_wr && spi_en && !busy;

  // ---- 总线写（下一拍 posedge 寄存） ----
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      spi_en  <= 1'b0;
      cpol    <= 1'b0;
      cpha    <= 1'b0;
      clk_div <= 8'd8;
      tx_data <= 8'h00;
    end
    else if (bus_valid && bus_wr) begin
      case (bus_addr)
        8'h00: begin
          spi_en <= bus_wdata[0];
          cpol   <= bus_wdata[1];
          cpha   <= bus_wdata[2];
        end
        8'h04: clk_div <= (bus_wdata[7:0] < 8'd2) ? 8'd2 : bus_wdata[7:0];
        8'h08: if (tx_accepted) tx_data <= bus_wdata[7:0];  // 忙/未使能时忽略
        default: ;
      endcase
    end
  end

  // ---- 总线读（组合逻辑，当拍返回） ----
  assign bus_ready = bus_valid;

  always_comb begin
    bus_rdata = 32'h0;
    if (bus_valid && !bus_wr) begin
      case (bus_addr)
        8'h00: bus_rdata = {29'h0, cpha, cpol, spi_en};
        8'h04: bus_rdata = {24'h0, clk_div};
        8'h08: bus_rdata = {24'h0, tx_data};
        8'h0C: bus_rdata = {24'h0, rx_data};
        8'h10: bus_rdata = {30'h0, rx_valid, busy};
        default: bus_rdata = 32'h0;
      endcase
    end
  end

  // ================= SPI 传输 FSM =================
  typedef enum logic [1:0] {IDLE, TRANSFER} state_e;
  state_e state;

  logic [7:0] shift_reg;   // 发送移位寄存器
  logic [7:0] rx_reg;      // 接收移位寄存器
  logic [7:0] div_cnt;     // sclk 半周期计数器
  logic [3:0] half_cnt;    // 半周期计数（8bit = 16 个半周期）

  wire [7:0]  half_period  = clk_div;

  // 半周期到点：sclk 翻转
  wire half_tick = (state == TRANSFER) && (div_cnt == half_period - 1'b1);

  // 边沿判定：
  //   前沿（leading） = sclk 离开空闲电平（CPOL）的那一拍
  //   后沿（trailing）= sclk 回到空闲电平的那一拍
  wire sclk_leading  = half_tick && (spi_sclk == cpol);
  wire sclk_trailing = half_tick && (spi_sclk != cpol);

  // CPHA=0：前沿采样、后沿移位；CPHA=1：前沿移位、后沿采样
  wire sample_edge = (cpha == 1'b0) ? sclk_leading : sclk_trailing;
  wire shift_edge  = (cpha == 1'b0) ? sclk_trailing : sclk_leading;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state     <= IDLE;
      spi_sclk  <= 1'b0;
      spi_cs_n  <= 1'b1;
      spi_mosi  <= 1'b0;
      busy      <= 1'b0;
      rx_valid  <= 1'b0;
      rx_data   <= 8'h00;
      div_cnt   <= 8'd0;
      half_cnt  <= 4'd0;
      shift_reg <= 8'h00;
      rx_reg    <= 8'h00;
    end
    else begin
      case (state)
        IDLE: begin
          spi_sclk <= cpol;      // 空闲电平 = CPOL
          spi_cs_n <= 1'b1;
          busy     <= 1'b0;
          div_cnt  <= 8'd0;
          half_cnt <= 4'd0;
          if (tx_accepted) begin
            // 启动一次 8bit 传输
            // CPHA=0：首 bit 在 cs 拉低时就要送到 MOSI（主机会在第一个前沿采样）
            // CPHA=1：首 bit 在第一个前沿（移位沿）送出
            spi_mosi  <= cpha ? 1'b0 : bus_wdata[7];
            shift_reg <= cpha ? bus_wdata[7:0] : {bus_wdata[6:0], 1'b0};
            rx_reg    <= 8'h00;
            rx_valid  <= 1'b0;   // 新传输启动，清除旧 rx_valid
            spi_cs_n  <= 1'b0;
            busy      <= 1'b1;
            state     <= TRANSFER;
          end
        end

        TRANSFER: begin
          if (half_tick) begin
            div_cnt  <= 8'd0;
            half_cnt <= half_cnt + 1'b1;
            spi_sclk <= ~spi_sclk;

            if (shift_edge) begin
              spi_mosi  <= shift_reg[7];
              shift_reg <= {shift_reg[6:0], 1'b0};
            end
            if (sample_edge) begin
              rx_reg <= {rx_reg[6:0], spi_miso};
            end
            // 第 16 个半周期结束：8 bit 传输完成
            if (half_cnt == 4'd15) begin
              state     <= IDLE;
              spi_cs_n  <= 1'b1;
              busy      <= 1'b0;
              rx_valid  <= 1'b1;
              // 注意：若完成拍同时是采样拍（CPHA=1），最后一 bit 要并入
              rx_data   <= sample_edge ? {rx_reg[6:0], spi_miso} : rx_reg;
            end
          end
          else begin
            div_cnt <= div_cnt + 1'b1;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule : spi_master
