`include "rggen_rtl_macros.vh"
module qspi_axi4lite_slv #(
  parameter ADDRESS_WIDTH = 8,
  parameter PRE_DECODE = 0,
  parameter [ADDRESS_WIDTH-1:0] BASE_ADDRESS = 0,
  parameter ERROR_STATUS = 0,
  parameter [31:0] DEFAULT_READ_DATA = 0,
  parameter INSERT_SLICER = 0,
  parameter ID_WIDTH = 0,
  parameter WRITE_FIRST = 1,
  parameter QSPI_CTRL_QSPI_ENABLE_INITIAL_VALUE = 1'h0,
  parameter [1:0] QSPI_CTRL_TRANS_DIR_INITIAL_VALUE = 2'h0,
  parameter [1:0] QSPI_CTRL_PROTOCOL_SEL_INITIAL_VALUE = 2'h0,
  parameter [3:0] QSPI_CTRL_WORD_WIDTH_INITIAL_VALUE = 4'h1,
  parameter QSPI_CTRL_SPI_SLAVE_EN_INITIAL_VALUE = 1'h0,
  parameter QSPI_CTRL_CPHA_INITIAL_VALUE = 1'h0,
  parameter QSPI_CTRL_CPOL_INITIAL_VALUE = 1'h0,
  parameter QSPI_CTRL_ORDER_INITIAL_VALUE = 1'h0,
  parameter [3:0] QSPI_CTRL_RX_LATCH_DELAY_INITIAL_VALUE = 4'h0,
  parameter QSPI_SW_RESET_SW_RST_N_INITIAL_VALUE = 1'h0,
  parameter QSPI_CS_CTRL_CS_MANUAL_INITIAL_VALUE = 1'h1,
  parameter QSPI_CS_CTRL_CS_MANUAL_EN_INITIAL_VALUE = 1'h0,
  parameter [1:0] QSPI_CS_CTRL_CS_SEL_INITIAL_VALUE = 2'h0,
  parameter [15:0] QSPI_MASTER_CLK_CLK_DIVISOR_INITIAL_VALUE = 16'h0000,
  parameter QSPI_DATA_RX_FIFO_CLR_INITIAL_VALUE = 1'h0,
  parameter QSPI_DATA_TX_FIFO_CLR_INITIAL_VALUE = 1'h0,
  parameter [15:0] QSPI_DATA_DATA_INITIAL_VALUE = 16'h0000,
  parameter QSPI_INT_RX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_TX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_TX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RX_FIFO_NOT_EMPTY_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter [4:0] QSPI_THRESHOLD_LEVEL_RX_THRESHOLD_LEVEL_INITIAL_VALUE = 5'h00,
  parameter [4:0] QSPI_THRESHOLD_LEVEL_TX_THRESHOLD_LEVEL_INITIAL_VALUE = 5'h00,
  parameter QSPI_STATUS_SPI_BUSY_INITIAL_VALUE = 1'h0,
  parameter [4:0] QSPI_STATUS_RX_FIFO_NUM_INITIAL_VALUE = 5'h00,
  parameter QSPI_STATUS_RX_FIFO_FULL_INITIAL_VALUE = 1'h0,
  parameter QSPI_STATUS_RX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter [4:0] QSPI_STATUS_TX_FIFO_AVAILABLE_INITIAL_VALUE = 5'h00,
  parameter QSPI_STATUS_TX_FIFO_FULL_INITIAL_VALUE = 1'h0,
  parameter QSPI_STATUS_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RS_RX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RS_TX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RS_RX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RS_TX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_RS_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_MS_RX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_MS_TX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_MS_RX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_MS_TX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_MS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE = 1'h0,
  parameter QSPI_INT_MS_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0
)(
  input i_clk,
  input i_rst_n,
  input i_awvalid,
  output o_awready,
  input [`rggen_clip_width(ID_WIDTH)-1:0] i_awid,
  input [ADDRESS_WIDTH-1:0] i_awaddr,
  input [2:0] i_awprot,
  input i_wvalid,
  output o_wready,
  input [31:0] i_wdata,
  input [3:0] i_wstrb,
  output o_bvalid,
  input i_bready,
  output [`rggen_clip_width(ID_WIDTH)-1:0] o_bid,
  output [1:0] o_bresp,
  input i_arvalid,
  output o_arready,
  input [`rggen_clip_width(ID_WIDTH)-1:0] i_arid,
  input [ADDRESS_WIDTH-1:0] i_araddr,
  input [2:0] i_arprot,
  output o_rvalid,
  input i_rready,
  output [`rggen_clip_width(ID_WIDTH)-1:0] o_rid,
  output [31:0] o_rdata,
  output [1:0] o_rresp,
  output o_qspi_ctrl_qspi_enable,
  output [1:0] o_qspi_ctrl_trans_dir,
  output [1:0] o_qspi_ctrl_protocol_sel,
  output [3:0] o_qspi_ctrl_word_width,
  output o_qspi_ctrl_spi_slave_en,
  output o_qspi_ctrl_cpha,
  output o_qspi_ctrl_cpol,
  output o_qspi_ctrl_order,
  output [3:0] o_qspi_ctrl_rx_latch_delay,
  output o_qspi_sw_reset_sw_rst_n,
  output o_qspi_cs_ctrl_cs_manual,
  output o_qspi_cs_ctrl_cs_manual_en,
  output [1:0] o_qspi_cs_ctrl_cs_sel,
  output [15:0] o_qspi_master_clk_clk_divisor,
  output o_qspi_data_rx_fifo_clr,
  output o_qspi_data_rx_fifo_clr_write_trigger,
  output o_qspi_data_tx_fifo_clr,
  output o_qspi_data_tx_fifo_clr_write_trigger,
  output [15:0] o_qspi_data_data,
  input [15:0] i_qspi_data_data,
  output o_qspi_data_data_write_trigger,
  output o_qspi_data_data_read_trigger,
  output o_qspi_int_rx_fifo_overflow,
  output o_qspi_int_tx_fifo_overflow,
  output o_qspi_int_rx_fifo_threshold,
  output o_qspi_int_tx_fifo_threshold,
  output o_qspi_int_rx_fifo_not_empty,
  output o_qspi_int_tx_fifo_empty,
  output [4:0] o_qspi_threshold_level_rx_threshold_level,
  output [4:0] o_qspi_threshold_level_tx_threshold_level,
  input i_qspi_status_spi_busy,
  input [4:0] i_qspi_status_rx_fifo_num,
  input i_qspi_status_rx_fifo_full,
  input i_qspi_status_rx_fifo_empty,
  input [4:0] i_qspi_status_tx_fifo_available,
  input i_qspi_status_tx_fifo_full,
  input i_qspi_status_tx_fifo_empty,
  input i_qspi_int_ms_rx_fifo_overflow_set,
  output o_qspi_int_ms_rx_fifo_overflow,
  output o_qspi_int_ms_rx_fifo_overflow_unmasked,
  input i_qspi_int_ms_tx_fifo_overflow_set,
  output o_qspi_int_ms_tx_fifo_overflow,
  output o_qspi_int_ms_tx_fifo_overflow_unmasked,
  input i_qspi_int_ms_rx_fifo_threshold_set,
  output o_qspi_int_ms_rx_fifo_threshold,
  output o_qspi_int_ms_rx_fifo_threshold_unmasked,
  input i_qspi_int_ms_tx_fifo_threshold_set,
  output o_qspi_int_ms_tx_fifo_threshold,
  output o_qspi_int_ms_tx_fifo_threshold_unmasked,
  input i_qspi_int_ms_rx_fifo_not_empty_set,
  output o_qspi_int_ms_rx_fifo_not_empty,
  output o_qspi_int_ms_rx_fifo_not_empty_unmasked,
  input i_qspi_int_ms_tx_fifo_empty_set,
  output o_qspi_int_ms_tx_fifo_empty,
  output o_qspi_int_ms_tx_fifo_empty_unmasked
);
  wire w_register_valid;
  wire [1:0] w_register_access;
  wire [7:0] w_register_address;
  wire [31:0] w_register_write_data;
  wire [31:0] w_register_strobe;
  wire [9:0] w_register_active;
  wire [9:0] w_register_ready;
  wire [19:0] w_register_status;
  wire [319:0] w_register_read_data;
  wire [319:0] w_register_value;
  rggen_axi4lite_adapter #(
    .ID_WIDTH             (ID_WIDTH),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH),
    .LOCAL_ADDRESS_WIDTH  (8),
    .BUS_WIDTH            (32),
    .REGISTERS            (10),
    .PRE_DECODE           (PRE_DECODE),
    .BASE_ADDRESS         (BASE_ADDRESS),
    .BYTE_SIZE            (256),
    .ERROR_STATUS         (ERROR_STATUS),
    .DEFAULT_READ_DATA    (DEFAULT_READ_DATA),
    .INSERT_SLICER        (INSERT_SLICER),
    .WRITE_FIRST          (WRITE_FIRST)
  ) u_adapter (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_awvalid              (i_awvalid),
    .o_awready              (o_awready),
    .i_awid                 (i_awid),
    .i_awaddr               (i_awaddr),
    .i_awprot               (i_awprot),
    .i_wvalid               (i_wvalid),
    .o_wready               (o_wready),
    .i_wdata                (i_wdata),
    .i_wstrb                (i_wstrb),
    .o_bvalid               (o_bvalid),
    .i_bready               (i_bready),
    .o_bid                  (o_bid),
    .o_bresp                (o_bresp),
    .i_arvalid              (i_arvalid),
    .o_arready              (o_arready),
    .i_arid                 (i_arid),
    .i_araddr               (i_araddr),
    .i_arprot               (i_arprot),
    .o_rvalid               (o_rvalid),
    .i_rready               (i_rready),
    .o_rid                  (o_rid),
    .o_rdata                (o_rdata),
    .o_rresp                (o_rresp),
    .o_register_valid       (w_register_valid),
    .o_register_access      (w_register_access),
    .o_register_address     (w_register_address),
    .o_register_write_data  (w_register_write_data),
    .o_register_strobe      (w_register_strobe),
    .i_register_active      (w_register_active),
    .i_register_ready       (w_register_ready),
    .i_register_status      (w_register_status),
    .i_register_read_data   (w_register_read_data)
  );
  generate if (1) begin : g_qspi_ctrl
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'hf131f331, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h00),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[0+:1]),
      .o_register_ready         (w_register_ready[0+:1]),
      .o_register_status        (w_register_status[0+:2]),
      .o_register_read_data     (w_register_read_data[0+:32]),
      .o_register_value         (w_register_value[0+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_qspi_enable
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_QSPI_ENABLE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_ctrl_qspi_enable),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_trans_dir
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (QSPI_CTRL_TRANS_DIR_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:2]),
        .i_sw_write_data    (w_bit_field_write_data[4+:2]),
        .o_sw_read_data     (w_bit_field_read_data[4+:2]),
        .o_sw_value         (w_bit_field_value[4+:2]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({2{1'b0}}),
        .i_hw_set           ({2{1'b0}}),
        .i_hw_clear         ({2{1'b0}}),
        .i_value            ({2{1'b0}}),
        .i_mask             ({2{1'b1}}),
        .o_value            (o_qspi_ctrl_trans_dir),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_protocol_sel
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (QSPI_CTRL_PROTOCOL_SEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[8+:2]),
        .i_sw_write_data    (w_bit_field_write_data[8+:2]),
        .o_sw_read_data     (w_bit_field_read_data[8+:2]),
        .o_sw_value         (w_bit_field_value[8+:2]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({2{1'b0}}),
        .i_hw_set           ({2{1'b0}}),
        .i_hw_clear         ({2{1'b0}}),
        .i_value            ({2{1'b0}}),
        .i_mask             ({2{1'b1}}),
        .o_value            (o_qspi_ctrl_protocol_sel),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_word_width
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (QSPI_CTRL_WORD_WIDTH_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[12+:4]),
        .i_sw_write_data    (w_bit_field_write_data[12+:4]),
        .o_sw_read_data     (w_bit_field_read_data[12+:4]),
        .o_sw_value         (w_bit_field_value[12+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_qspi_ctrl_word_width),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_spi_slave_en
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_SPI_SLAVE_EN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[16+:1]),
        .i_sw_write_data    (w_bit_field_write_data[16+:1]),
        .o_sw_read_data     (w_bit_field_read_data[16+:1]),
        .o_sw_value         (w_bit_field_value[16+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_ctrl_spi_slave_en),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cpha
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_CPHA_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[20+:1]),
        .i_sw_write_data    (w_bit_field_write_data[20+:1]),
        .o_sw_read_data     (w_bit_field_read_data[20+:1]),
        .o_sw_value         (w_bit_field_value[20+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_ctrl_cpha),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cpol
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_CPOL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[21+:1]),
        .i_sw_write_data    (w_bit_field_write_data[21+:1]),
        .o_sw_read_data     (w_bit_field_read_data[21+:1]),
        .o_sw_value         (w_bit_field_value[21+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_ctrl_cpol),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_order
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_ORDER_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[24+:1]),
        .i_sw_write_data    (w_bit_field_write_data[24+:1]),
        .o_sw_read_data     (w_bit_field_read_data[24+:1]),
        .o_sw_value         (w_bit_field_value[24+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_ctrl_order),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_latch_delay
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (QSPI_CTRL_RX_LATCH_DELAY_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[28+:4]),
        .i_sw_write_data    (w_bit_field_write_data[28+:4]),
        .o_sw_read_data     (w_bit_field_read_data[28+:4]),
        .o_sw_value         (w_bit_field_value[28+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_qspi_ctrl_rx_latch_delay),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_sw_reset
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00000001, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h04),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[1+:1]),
      .o_register_ready         (w_register_ready[1+:1]),
      .o_register_status        (w_register_status[2+:2]),
      .o_register_read_data     (w_register_read_data[32+:32]),
      .o_register_value         (w_register_value[32+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_sw_rst_n
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_SW_RESET_SW_RST_N_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_sw_reset_sw_rst_n),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_cs_ctrl
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00000113, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h08),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[2+:1]),
      .o_register_ready         (w_register_ready[2+:1]),
      .o_register_status        (w_register_status[4+:2]),
      .o_register_read_data     (w_register_read_data[64+:32]),
      .o_register_value         (w_register_value[64+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_cs_manual
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CS_CTRL_CS_MANUAL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[8+:1]),
        .i_sw_write_data    (w_bit_field_write_data[8+:1]),
        .o_sw_read_data     (w_bit_field_read_data[8+:1]),
        .o_sw_value         (w_bit_field_value[8+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_cs_ctrl_cs_manual),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cs_manual_en
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CS_CTRL_CS_MANUAL_EN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_cs_ctrl_cs_manual_en),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cs_sel
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (QSPI_CS_CTRL_CS_SEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:2]),
        .i_sw_write_data    (w_bit_field_write_data[0+:2]),
        .o_sw_read_data     (w_bit_field_read_data[0+:2]),
        .o_sw_value         (w_bit_field_value[0+:2]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({2{1'b0}}),
        .i_hw_set           ({2{1'b0}}),
        .i_hw_clear         ({2{1'b0}}),
        .i_value            ({2{1'b0}}),
        .i_mask             ({2{1'b1}}),
        .o_value            (o_qspi_cs_ctrl_cs_sel),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_master_clk
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000ffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[3+:1]),
      .o_register_ready         (w_register_ready[3+:1]),
      .o_register_status        (w_register_status[6+:2]),
      .o_register_read_data     (w_register_read_data[96+:32]),
      .o_register_value         (w_register_value[96+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_clk_divisor
      rggen_bit_field #(
        .WIDTH          (16),
        .INITIAL_VALUE  (QSPI_MASTER_CLK_CLK_DIVISOR_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:16]),
        .i_sw_write_data    (w_bit_field_write_data[0+:16]),
        .o_sw_read_data     (w_bit_field_read_data[0+:16]),
        .o_sw_value         (w_bit_field_value[0+:16]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({16{1'b0}}),
        .i_hw_set           ({16{1'b0}}),
        .i_hw_clear         ({16{1'b0}}),
        .i_value            ({16{1'b0}}),
        .i_mask             ({16{1'b1}}),
        .o_value            (o_qspi_master_clk_clk_divisor),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_data
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0003ffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h10),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[4+:1]),
      .o_register_ready         (w_register_ready[4+:1]),
      .o_register_status        (w_register_status[8+:2]),
      .o_register_read_data     (w_register_read_data[128+:32]),
      .o_register_value         (w_register_value[128+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_rx_fifo_clr
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_DATA_RX_FIFO_CLR_INITIAL_VALUE),
        .SW_READ_ACTION (`RGGEN_READ_NONE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[17+:1]),
        .i_sw_write_data    (w_bit_field_write_data[17+:1]),
        .o_sw_read_data     (w_bit_field_read_data[17+:1]),
        .o_sw_value         (w_bit_field_value[17+:1]),
        .o_write_trigger    (o_qspi_data_rx_fifo_clr_write_trigger),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_data_rx_fifo_clr),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_clr
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_DATA_TX_FIFO_CLR_INITIAL_VALUE),
        .SW_READ_ACTION (`RGGEN_READ_NONE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[16+:1]),
        .i_sw_write_data    (w_bit_field_write_data[16+:1]),
        .o_sw_read_data     (w_bit_field_read_data[16+:1]),
        .o_sw_value         (w_bit_field_value[16+:1]),
        .o_write_trigger    (o_qspi_data_tx_fifo_clr_write_trigger),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_data_tx_fifo_clr),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_data
      rggen_bit_field #(
        .WIDTH              (16),
        .INITIAL_VALUE      (QSPI_DATA_DATA_INITIAL_VALUE),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:16]),
        .i_sw_write_data    (w_bit_field_write_data[0+:16]),
        .o_sw_read_data     (w_bit_field_read_data[0+:16]),
        .o_sw_value         (w_bit_field_value[0+:16]),
        .o_write_trigger    (o_qspi_data_data_write_trigger),
        .o_read_trigger     (o_qspi_data_data_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({16{1'b0}}),
        .i_hw_set           ({16{1'b0}}),
        .i_hw_clear         ({16{1'b0}}),
        .i_value            (i_qspi_data_data),
        .i_mask             ({16{1'b1}}),
        .o_value            (o_qspi_data_data),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_int
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00111111, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h14),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[5+:1]),
      .o_register_ready         (w_register_ready[5+:1]),
      .o_register_status        (w_register_status[10+:2]),
      .o_register_read_data     (w_register_read_data[160+:32]),
      .o_register_value         (w_register_value[160+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_rx_fifo_overflow
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_RX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[20+:1]),
        .i_sw_write_data    (w_bit_field_write_data[20+:1]),
        .o_sw_read_data     (w_bit_field_read_data[20+:1]),
        .o_sw_value         (w_bit_field_value[20+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_int_rx_fifo_overflow),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_overflow
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_TX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[16+:1]),
        .i_sw_write_data    (w_bit_field_write_data[16+:1]),
        .o_sw_read_data     (w_bit_field_read_data[16+:1]),
        .o_sw_value         (w_bit_field_value[16+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_int_tx_fifo_overflow),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_threshold
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_RX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[12+:1]),
        .i_sw_write_data    (w_bit_field_write_data[12+:1]),
        .o_sw_read_data     (w_bit_field_read_data[12+:1]),
        .o_sw_value         (w_bit_field_value[12+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_int_rx_fifo_threshold),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_threshold
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_TX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[8+:1]),
        .i_sw_write_data    (w_bit_field_write_data[8+:1]),
        .o_sw_read_data     (w_bit_field_read_data[8+:1]),
        .o_sw_value         (w_bit_field_value[8+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_int_tx_fifo_threshold),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_not_empty
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_RX_FIFO_NOT_EMPTY_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_int_rx_fifo_not_empty),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_TX_FIFO_EMPTY_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qspi_int_tx_fifo_empty),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_threshold_level
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00001f1f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h18),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[6+:1]),
      .o_register_ready         (w_register_ready[6+:1]),
      .o_register_status        (w_register_status[12+:2]),
      .o_register_read_data     (w_register_read_data[192+:32]),
      .o_register_value         (w_register_value[192+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_rx_threshold_level
      rggen_bit_field #(
        .WIDTH          (5),
        .INITIAL_VALUE  (QSPI_THRESHOLD_LEVEL_RX_THRESHOLD_LEVEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[8+:5]),
        .i_sw_write_data    (w_bit_field_write_data[8+:5]),
        .o_sw_read_data     (w_bit_field_read_data[8+:5]),
        .o_sw_value         (w_bit_field_value[8+:5]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({5{1'b0}}),
        .i_hw_set           ({5{1'b0}}),
        .i_hw_clear         ({5{1'b0}}),
        .i_value            ({5{1'b0}}),
        .i_mask             ({5{1'b1}}),
        .o_value            (o_qspi_threshold_level_rx_threshold_level),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_threshold_level
      rggen_bit_field #(
        .WIDTH          (5),
        .INITIAL_VALUE  (QSPI_THRESHOLD_LEVEL_TX_THRESHOLD_LEVEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:5]),
        .i_sw_write_data    (w_bit_field_write_data[0+:5]),
        .o_sw_read_data     (w_bit_field_read_data[0+:5]),
        .o_sw_value         (w_bit_field_value[0+:5]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({5{1'b0}}),
        .i_hw_set           ({5{1'b0}}),
        .i_hw_clear         ({5{1'b0}}),
        .i_value            ({5{1'b0}}),
        .i_mask             ({5{1'b1}}),
        .o_value            (o_qspi_threshold_level_tx_threshold_level),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_status
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h011f31f3, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h1c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[7+:1]),
      .o_register_ready         (w_register_ready[7+:1]),
      .o_register_status        (w_register_status[14+:2]),
      .o_register_read_data     (w_register_read_data[224+:32]),
      .o_register_value         (w_register_value[224+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_spi_busy
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[24+:1]),
        .i_sw_write_data    (w_bit_field_write_data[24+:1]),
        .o_sw_read_data     (w_bit_field_read_data[24+:1]),
        .o_sw_value         (w_bit_field_value[24+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_qspi_status_spi_busy),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_num
      rggen_bit_field #(
        .WIDTH              (5),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[16+:5]),
        .i_sw_write_data    (w_bit_field_write_data[16+:5]),
        .o_sw_read_data     (w_bit_field_read_data[16+:5]),
        .o_sw_value         (w_bit_field_value[16+:5]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({5{1'b0}}),
        .i_hw_set           ({5{1'b0}}),
        .i_hw_clear         ({5{1'b0}}),
        .i_value            (i_qspi_status_rx_fifo_num),
        .i_mask             ({5{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_full
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[13+:1]),
        .i_sw_write_data    (w_bit_field_write_data[13+:1]),
        .o_sw_read_data     (w_bit_field_read_data[13+:1]),
        .o_sw_value         (w_bit_field_value[13+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_qspi_status_rx_fifo_full),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_empty
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[12+:1]),
        .i_sw_write_data    (w_bit_field_write_data[12+:1]),
        .o_sw_read_data     (w_bit_field_read_data[12+:1]),
        .o_sw_value         (w_bit_field_value[12+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_qspi_status_rx_fifo_empty),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_available
      rggen_bit_field #(
        .WIDTH              (5),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[4+:5]),
        .i_sw_write_data    (w_bit_field_write_data[4+:5]),
        .o_sw_read_data     (w_bit_field_read_data[4+:5]),
        .o_sw_value         (w_bit_field_value[4+:5]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({5{1'b0}}),
        .i_hw_set           ({5{1'b0}}),
        .i_hw_clear         ({5{1'b0}}),
        .i_value            (i_qspi_status_tx_fifo_available),
        .i_mask             ({5{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_full
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_qspi_status_tx_fifo_full),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_qspi_status_tx_fifo_empty),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_int_rs
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00111111, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h20),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[8+:1]),
      .o_register_ready         (w_register_ready[8+:1]),
      .o_register_status        (w_register_status[16+:2]),
      .o_register_read_data     (w_register_read_data[256+:32]),
      .o_register_value         (w_register_value[256+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_rx_fifo_overflow
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[20+:1]),
        .i_sw_write_data    (w_bit_field_write_data[20+:1]),
        .o_sw_read_data     (w_bit_field_read_data[20+:1]),
        .o_sw_value         (w_bit_field_value[20+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (w_register_value[308+:1]),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_overflow
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[16+:1]),
        .i_sw_write_data    (w_bit_field_write_data[16+:1]),
        .o_sw_read_data     (w_bit_field_read_data[16+:1]),
        .o_sw_value         (w_bit_field_value[16+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (w_register_value[304+:1]),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_threshold
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[12+:1]),
        .i_sw_write_data    (w_bit_field_write_data[12+:1]),
        .o_sw_read_data     (w_bit_field_read_data[12+:1]),
        .o_sw_value         (w_bit_field_value[12+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (w_register_value[300+:1]),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_threshold
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[8+:1]),
        .i_sw_write_data    (w_bit_field_write_data[8+:1]),
        .o_sw_read_data     (w_bit_field_read_data[8+:1]),
        .o_sw_value         (w_bit_field_value[8+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (w_register_value[296+:1]),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_not_empty
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (w_register_value[292+:1]),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (w_register_value[288+:1]),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_int_ms
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00111111, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h24),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[9+:1]),
      .o_register_ready         (w_register_ready[9+:1]),
      .o_register_status        (w_register_status[18+:2]),
      .o_register_read_data     (w_register_read_data[288+:32]),
      .o_register_value         (w_register_value[288+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_rx_fifo_overflow
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_RX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_READ_ACTION   (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (`RGGEN_WRITE_1_CLEAR),
        .HW_ACCESS        (3'b010),
        .EXTERNAL_MASK    (1'b1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[20+:1]),
        .i_sw_write_data    (w_bit_field_write_data[20+:1]),
        .o_sw_read_data     (w_bit_field_read_data[20+:1]),
        .o_sw_value         (w_bit_field_value[20+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_qspi_int_ms_rx_fifo_overflow_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             (w_register_value[180+:1]),
        .o_value            (o_qspi_int_ms_rx_fifo_overflow),
        .o_value_unmasked   (o_qspi_int_ms_rx_fifo_overflow_unmasked)
      );
    end
    if (1) begin : g_tx_fifo_overflow
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_TX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_READ_ACTION   (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (`RGGEN_WRITE_1_CLEAR),
        .HW_ACCESS        (3'b010),
        .EXTERNAL_MASK    (1'b1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[16+:1]),
        .i_sw_write_data    (w_bit_field_write_data[16+:1]),
        .o_sw_read_data     (w_bit_field_read_data[16+:1]),
        .o_sw_value         (w_bit_field_value[16+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_qspi_int_ms_tx_fifo_overflow_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             (w_register_value[176+:1]),
        .o_value            (o_qspi_int_ms_tx_fifo_overflow),
        .o_value_unmasked   (o_qspi_int_ms_tx_fifo_overflow_unmasked)
      );
    end
    if (1) begin : g_rx_fifo_threshold
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_RX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_READ_ACTION   (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (`RGGEN_WRITE_1_CLEAR),
        .HW_ACCESS        (3'b010),
        .EXTERNAL_MASK    (1'b1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[12+:1]),
        .i_sw_write_data    (w_bit_field_write_data[12+:1]),
        .o_sw_read_data     (w_bit_field_read_data[12+:1]),
        .o_sw_value         (w_bit_field_value[12+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_qspi_int_ms_rx_fifo_threshold_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             (w_register_value[172+:1]),
        .o_value            (o_qspi_int_ms_rx_fifo_threshold),
        .o_value_unmasked   (o_qspi_int_ms_rx_fifo_threshold_unmasked)
      );
    end
    if (1) begin : g_tx_fifo_threshold
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_TX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_READ_ACTION   (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (`RGGEN_WRITE_1_CLEAR),
        .HW_ACCESS        (3'b010),
        .EXTERNAL_MASK    (1'b1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[8+:1]),
        .i_sw_write_data    (w_bit_field_write_data[8+:1]),
        .o_sw_read_data     (w_bit_field_read_data[8+:1]),
        .o_sw_value         (w_bit_field_value[8+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_qspi_int_ms_tx_fifo_threshold_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             (w_register_value[168+:1]),
        .o_value            (o_qspi_int_ms_tx_fifo_threshold),
        .o_value_unmasked   (o_qspi_int_ms_tx_fifo_threshold_unmasked)
      );
    end
    if (1) begin : g_rx_fifo_not_empty
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE),
        .SW_READ_ACTION   (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (`RGGEN_WRITE_1_CLEAR),
        .HW_ACCESS        (3'b010),
        .EXTERNAL_MASK    (1'b1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_qspi_int_ms_rx_fifo_not_empty_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             (w_register_value[164+:1]),
        .o_value            (o_qspi_int_ms_rx_fifo_not_empty),
        .o_value_unmasked   (o_qspi_int_ms_rx_fifo_not_empty_unmasked)
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_TX_FIFO_EMPTY_INITIAL_VALUE),
        .SW_READ_ACTION   (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (`RGGEN_WRITE_1_CLEAR),
        .HW_ACCESS        (3'b010),
        .EXTERNAL_MASK    (1'b1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_qspi_int_ms_tx_fifo_empty_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             (w_register_value[160+:1]),
        .o_value            (o_qspi_int_ms_tx_fifo_empty),
        .o_value_unmasked   (o_qspi_int_ms_tx_fifo_empty_unmasked)
      );
    end
  end endgenerate
endmodule
