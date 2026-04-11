`ifndef rggen_connect_bit_field_if
  `define rggen_connect_bit_field_if(RIF, FIF, LSB, WIDTH) \
  assign  FIF.valid                 = RIF.valid; \
  assign  FIF.read_mask             = RIF.read_mask[LSB+:WIDTH]; \
  assign  FIF.write_mask            = RIF.write_mask[LSB+:WIDTH]; \
  assign  FIF.write_data            = RIF.write_data[LSB+:WIDTH]; \
  assign  RIF.read_data[LSB+:WIDTH] = FIF.read_data; \
  assign  RIF.value[LSB+:WIDTH]     = FIF.value;
`endif
`ifndef rggen_tie_off_unused_signals
  `define rggen_tie_off_unused_signals(WIDTH, VALID_BITS, RIF) \
  if (1) begin : __g_tie_off \
    genvar  __i; \
    for (__i = 0;__i < WIDTH;++__i) begin : g \
      if ((((VALID_BITS) >> __i) % 2) == 0) begin : g \
        assign  RIF.read_data[__i]  = 1'b0; \
        assign  RIF.value[__i]      = 1'b0; \
      end \
    end \
  end
`endif
module qspi_axi4lite_slv
  import rggen_rtl_pkg::*;
#(
  parameter int ADDRESS_WIDTH = 8,
  parameter bit PRE_DECODE = 0,
  parameter bit [ADDRESS_WIDTH-1:0] BASE_ADDRESS = '0,
  parameter bit ERROR_STATUS = 0,
  parameter bit [31:0] DEFAULT_READ_DATA = '0,
  parameter bit INSERT_SLICER = 0,
  parameter int ID_WIDTH = 0,
  parameter bit WRITE_FIRST = 1,
  parameter bit QSPI_CTRL_QSPI_ENABLE_INITIAL_VALUE = 1'h0,
  parameter bit [1:0] QSPI_CTRL_TRANS_DIR_INITIAL_VALUE = 2'h0,
  parameter bit [1:0] QSPI_CTRL_PROTOCOL_SEL_INITIAL_VALUE = 2'h0,
  parameter bit [3:0] QSPI_CTRL_WORD_WIDTH_INITIAL_VALUE = 4'h0,
  parameter bit QSPI_CTRL_SPI_SLAVE_EN_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_CTRL_CPOL_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_CTRL_CPHA_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_CTRL_ORDER_INITIAL_VALUE = 1'h0,
  parameter bit [3:0] QSPI_CTRL_RX_LATCH_DELAY_INITIAL_VALUE = 4'h0,
  parameter bit QSPI_SW_RESET_SW_RST_N_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_CS_CTRL_CS_MANUAL_INITIAL_VALUE = 1'h1,
  parameter bit QSPI_CS_CTRL_CS_MANUAL_EN_INITIAL_VALUE = 1'h0,
  parameter bit [1:0] QSPI_CS_CTRL_CS_SEL_INITIAL_VALUE = 2'h0,
  parameter bit [15:0] QSPI_MASTER_CLK_CLK_DIVISOR_INITIAL_VALUE = 16'h0000,
  parameter bit QSPI_DATA_RX_FIFO_CLR_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_DATA_TX_FIFO_CLR_INITIAL_VALUE = 1'h0,
  parameter bit [15:0] QSPI_DATA_DATA_INITIAL_VALUE = 16'h0000,
  parameter bit QSPI_INT_RX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_TX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_TX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RX_FIFO_NOT_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit [4:0] QSPI_THESHOLD_LEVEL_RX_THESHOLD_LEVEL_INITIAL_VALUE = 5'h00,
  parameter bit [4:0] QSPI_THESHOLD_LEVEL_TX_THESHOLD_LEVEL_INITIAL_VALUE = 5'h00,
  parameter bit QSPI_STATUS_SPI_BUSY_INITIAL_VALUE = 1'h0,
  parameter bit [4:0] QSPI_STATUS_RX_FIFO_NUM_INITIAL_VALUE = 5'h00,
  parameter bit QSPI_STATUS_RX_FIFO_FULL_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_STATUS_RX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit [4:0] QSPI_STATUS_TX_FIFO_AVAILABLE_INITIAL_VALUE = 5'h00,
  parameter bit QSPI_STATUS_TX_FIFO_FULL_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_STATUS_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RS_RX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RS_TX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RS_RX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RS_TX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_RS_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_MS_RX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_MS_TX_FIFO_OVERFLOW_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_MS_RX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_MS_TX_FIFO_THRESHOLD_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_MS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE = 1'h0,
  parameter bit QSPI_INT_MS_TX_FIFO_EMPTY_INITIAL_VALUE = 1'h0
)(
  input logic i_clk,
  input logic i_rst_n,
  rggen_axi4lite_if.slave axi4lite_if,
  output logic o_qspi_ctrl_qspi_enable,
  output logic [1:0] o_qspi_ctrl_trans_dir,
  output logic [1:0] o_qspi_ctrl_protocol_sel,
  output logic [3:0] o_qspi_ctrl_word_width,
  output logic o_qspi_ctrl_spi_slave_en,
  output logic o_qspi_ctrl_cpol,
  output logic o_qspi_ctrl_cpha,
  output logic o_qspi_ctrl_order,
  output logic [3:0] o_qspi_ctrl_rx_latch_delay,
  output logic o_qspi_sw_reset_sw_rst_n,
  output logic o_qspi_cs_ctrl_cs_manual,
  output logic o_qspi_cs_ctrl_cs_manual_en,
  output logic [1:0] o_qspi_cs_ctrl_cs_sel,
  output logic [15:0] o_qspi_master_clk_clk_divisor,
  output logic o_qspi_data_rx_fifo_clr,
  output logic o_qspi_data_rx_fifo_clr_write_trigger,
  output logic o_qspi_data_tx_fifo_clr,
  output logic o_qspi_data_tx_fifo_clr_write_trigger,
  output logic [15:0] o_qspi_data_data,
  input logic [15:0] i_qspi_data_data,
  output logic o_qspi_data_data_write_trigger,
  output logic o_qspi_data_data_read_trigger,
  output logic o_qspi_int_rx_fifo_overflow,
  output logic o_qspi_int_tx_fifo_overflow,
  output logic o_qspi_int_rx_fifo_threshold,
  output logic o_qspi_int_tx_fifo_threshold,
  output logic o_qspi_int_rx_fifo_not_empty,
  output logic o_qspi_int_tx_fifo_empty,
  output logic [4:0] o_qspi_theshold_level_rx_theshold_level,
  output logic [4:0] o_qspi_theshold_level_tx_theshold_level,
  input logic i_qspi_status_spi_busy,
  input logic [4:0] i_qspi_status_rx_fifo_num,
  input logic i_qspi_status_rx_fifo_full,
  input logic i_qspi_status_rx_fifo_empty,
  input logic [4:0] i_qspi_status_tx_fifo_available,
  input logic i_qspi_status_tx_fifo_full,
  input logic i_qspi_status_tx_fifo_empty,
  input logic i_qspi_int_ms_rx_fifo_overflow_set,
  output logic o_qspi_int_ms_rx_fifo_overflow,
  output logic o_qspi_int_ms_rx_fifo_overflow_unmasked,
  input logic i_qspi_int_ms_tx_fifo_overflow_set,
  output logic o_qspi_int_ms_tx_fifo_overflow,
  output logic o_qspi_int_ms_tx_fifo_overflow_unmasked,
  input logic i_qspi_int_ms_rx_fifo_threshold_set,
  output logic o_qspi_int_ms_rx_fifo_threshold,
  output logic o_qspi_int_ms_rx_fifo_threshold_unmasked,
  input logic i_qspi_int_ms_tx_fifo_threshold_set,
  output logic o_qspi_int_ms_tx_fifo_threshold,
  output logic o_qspi_int_ms_tx_fifo_threshold_unmasked,
  input logic i_qspi_int_ms_rx_fifo_not_empty_set,
  output logic o_qspi_int_ms_rx_fifo_not_empty,
  output logic o_qspi_int_ms_rx_fifo_not_empty_unmasked,
  input logic i_qspi_int_ms_tx_fifo_empty_set,
  output logic o_qspi_int_ms_tx_fifo_empty,
  output logic o_qspi_int_ms_tx_fifo_empty_unmasked
);
  rggen_register_if #(8, 32, 32) register_if[10]();
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
    .i_clk        (i_clk),
    .i_rst_n      (i_rst_n),
    .axi4lite_if  (axi4lite_if),
    .register_if  (register_if)
  );
  generate if (1) begin : g_qspi_ctrl
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hf131f331, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h00),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[0]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_qspi_enable
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_QSPI_ENABLE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_qspi_enable),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_trans_dir
      rggen_bit_field_if #(2) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 2)
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (QSPI_CTRL_TRANS_DIR_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_trans_dir),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_protocol_sel
      rggen_bit_field_if #(2) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 2)
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (QSPI_CTRL_PROTOCOL_SEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_protocol_sel),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_word_width
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 12, 4)
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (QSPI_CTRL_WORD_WIDTH_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_word_width),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_spi_slave_en
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_SPI_SLAVE_EN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_spi_slave_en),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cpol
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 20, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_CPOL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_cpol),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cpha
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 21, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_CPHA_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_cpha),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_order
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 24, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CTRL_ORDER_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_order),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_latch_delay
      rggen_bit_field_if #(4) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 28, 4)
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (QSPI_CTRL_RX_LATCH_DELAY_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_ctrl_rx_latch_delay),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_sw_reset
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h00000001, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h04),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[1]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_sw_rst_n
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_SW_RESET_SW_RST_N_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_sw_reset_sw_rst_n),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_cs_ctrl
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h00000113, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h08),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[2]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_cs_manual
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CS_CTRL_CS_MANUAL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_cs_ctrl_cs_manual),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cs_manual_en
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_CS_CTRL_CS_MANUAL_EN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_cs_ctrl_cs_manual_en),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cs_sel
      rggen_bit_field_if #(2) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 2)
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (QSPI_CS_CTRL_CS_SEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_cs_ctrl_cs_sel),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_master_clk
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h0000ffff, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[3]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_clk_divisor
      rggen_bit_field_if #(16) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 16)
      rggen_bit_field #(
        .WIDTH          (16),
        .INITIAL_VALUE  (QSPI_MASTER_CLK_CLK_DIVISOR_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_master_clk_clk_divisor),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_data
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h0003ffff, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h10),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[4]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_rx_fifo_clr
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 17, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_DATA_RX_FIFO_CLR_INITIAL_VALUE),
        .SW_READ_ACTION (RGGEN_READ_NONE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (o_qspi_data_rx_fifo_clr_write_trigger),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_data_rx_fifo_clr),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_clr
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_DATA_TX_FIFO_CLR_INITIAL_VALUE),
        .SW_READ_ACTION (RGGEN_READ_NONE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (o_qspi_data_tx_fifo_clr_write_trigger),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_data_tx_fifo_clr),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_data
      rggen_bit_field_if #(16) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 16)
      rggen_bit_field #(
        .WIDTH              (16),
        .INITIAL_VALUE      (QSPI_DATA_DATA_INITIAL_VALUE),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (o_qspi_data_data_write_trigger),
        .o_read_trigger     (o_qspi_data_data_read_trigger),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_data_data),
        .i_mask             ('1),
        .o_value            (o_qspi_data_data),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_int
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h00111111, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h14),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[5]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_rx_fifo_overflow
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 20, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_RX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_int_rx_fifo_overflow),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_overflow
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_TX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_int_tx_fifo_overflow),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_threshold
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 12, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_RX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_int_rx_fifo_threshold),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_threshold
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_TX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_int_tx_fifo_threshold),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_not_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_RX_FIFO_NOT_EMPTY_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_int_rx_fifo_not_empty),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSPI_INT_TX_FIFO_EMPTY_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_int_tx_fifo_empty),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_theshold_level
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h00001f1f, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h18),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[6]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_rx_theshold_level
      rggen_bit_field_if #(5) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 5)
      rggen_bit_field #(
        .WIDTH          (5),
        .INITIAL_VALUE  (QSPI_THESHOLD_LEVEL_RX_THESHOLD_LEVEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_theshold_level_rx_theshold_level),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_theshold_level
      rggen_bit_field_if #(5) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 5)
      rggen_bit_field #(
        .WIDTH          (5),
        .INITIAL_VALUE  (QSPI_THESHOLD_LEVEL_TX_THESHOLD_LEVEL_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_qspi_theshold_level_tx_theshold_level),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_status
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h011f31f3, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h1c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[7]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_spi_busy
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 24, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_spi_busy),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_num
      rggen_bit_field_if #(5) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 5)
      rggen_bit_field #(
        .WIDTH              (5),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_rx_fifo_num),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_full
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 13, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_rx_fifo_full),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 12, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_rx_fifo_empty),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_available
      rggen_bit_field_if #(5) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 5)
      rggen_bit_field #(
        .WIDTH              (5),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_tx_fifo_available),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_full
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 1, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_tx_fifo_full),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_qspi_status_tx_fifo_empty),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_int_rs
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h00111111, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h20),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[8]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_rx_fifo_overflow
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 20, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (register_if[9].value[20+:1]),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_overflow
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (register_if[9].value[16+:1]),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_threshold
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 12, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (register_if[9].value[12+:1]),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_threshold
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (register_if[9].value[8+:1]),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rx_fifo_not_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (register_if[9].value[4+:1]),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (register_if[9].value[0+:1]),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qspi_int_ms
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'h00111111, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h24),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[9]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_rx_fifo_overflow
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 20, 1)
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_RX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_READ_ACTION   (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (RGGEN_WRITE_1_CLEAR)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_qspi_int_ms_rx_fifo_overflow_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             (register_if[5].value[20+:1]),
        .o_value            (o_qspi_int_ms_rx_fifo_overflow),
        .o_value_unmasked   (o_qspi_int_ms_rx_fifo_overflow_unmasked)
      );
    end
    if (1) begin : g_tx_fifo_overflow
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 1)
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_TX_FIFO_OVERFLOW_INITIAL_VALUE),
        .SW_READ_ACTION   (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (RGGEN_WRITE_1_CLEAR)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_qspi_int_ms_tx_fifo_overflow_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             (register_if[5].value[16+:1]),
        .o_value            (o_qspi_int_ms_tx_fifo_overflow),
        .o_value_unmasked   (o_qspi_int_ms_tx_fifo_overflow_unmasked)
      );
    end
    if (1) begin : g_rx_fifo_threshold
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 12, 1)
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_RX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_READ_ACTION   (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (RGGEN_WRITE_1_CLEAR)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_qspi_int_ms_rx_fifo_threshold_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             (register_if[5].value[12+:1]),
        .o_value            (o_qspi_int_ms_rx_fifo_threshold),
        .o_value_unmasked   (o_qspi_int_ms_rx_fifo_threshold_unmasked)
      );
    end
    if (1) begin : g_tx_fifo_threshold
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 1)
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_TX_FIFO_THRESHOLD_INITIAL_VALUE),
        .SW_READ_ACTION   (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (RGGEN_WRITE_1_CLEAR)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_qspi_int_ms_tx_fifo_threshold_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             (register_if[5].value[8+:1]),
        .o_value            (o_qspi_int_ms_tx_fifo_threshold),
        .o_value_unmasked   (o_qspi_int_ms_tx_fifo_threshold_unmasked)
      );
    end
    if (1) begin : g_rx_fifo_not_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 1)
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE),
        .SW_READ_ACTION   (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (RGGEN_WRITE_1_CLEAR)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_qspi_int_ms_rx_fifo_not_empty_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             (register_if[5].value[4+:1]),
        .o_value            (o_qspi_int_ms_rx_fifo_not_empty),
        .o_value_unmasked   (o_qspi_int_ms_rx_fifo_not_empty_unmasked)
      );
    end
    if (1) begin : g_tx_fifo_empty
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH            (1),
        .INITIAL_VALUE    (QSPI_INT_MS_TX_FIFO_EMPTY_INITIAL_VALUE),
        .SW_READ_ACTION   (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION  (RGGEN_WRITE_1_CLEAR)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_qspi_int_ms_tx_fifo_empty_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             (register_if[5].value[0+:1]),
        .o_value            (o_qspi_int_ms_tx_fifo_empty),
        .o_value_unmasked   (o_qspi_int_ms_tx_fifo_empty_unmasked)
      );
    end
  end endgenerate
endmodule
