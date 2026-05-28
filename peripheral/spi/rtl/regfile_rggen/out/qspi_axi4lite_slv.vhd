library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rggen_rtl.all;

entity qspi_axi4lite_slv is
  generic (
    ADDRESS_WIDTH: positive := 8;
    PRE_DECODE: boolean := false;
    BASE_ADDRESS: unsigned := x"0";
    ERROR_STATUS: boolean := false;
    INSERT_SLICER: boolean := false;
    ID_WIDTH: natural := 0;
    WRITE_FIRST: boolean := true;
    QSPI_CTRL_QSPI_ENABLE_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CTRL_TRANS_DIR_INITIAL_VALUE: unsigned(1 downto 0) := repeat(x"0", 2, 1);
    QSPI_CTRL_PROTOCOL_SEL_INITIAL_VALUE: unsigned(1 downto 0) := repeat(x"0", 2, 1);
    QSPI_CTRL_WORD_WIDTH_INITIAL_VALUE: unsigned(3 downto 0) := repeat(x"1", 4, 1);
    QSPI_CTRL_SPI_SLAVE_EN_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CTRL_CPHA_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CTRL_CPOL_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CTRL_ORDER_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CTRL_RX_LATCH_DELAY_INITIAL_VALUE: unsigned(3 downto 0) := repeat(x"0", 4, 1);
    QSPI_SW_RESET_SW_RST_N_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CS_CTRL_CS_MANUAL_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"1", 1, 1);
    QSPI_CS_CTRL_CS_MANUAL_EN_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_CS_CTRL_CS_SEL_INITIAL_VALUE: unsigned(1 downto 0) := repeat(x"0", 2, 1);
    QSPI_MASTER_CLK_CLK_DIVISOR_INITIAL_VALUE: unsigned(15 downto 0) := repeat(x"0000", 16, 1);
    QSPI_DATA_RX_FIFO_CLR_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_DATA_TX_FIFO_CLR_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_DATA_DATA_INITIAL_VALUE: unsigned(15 downto 0) := repeat(x"0000", 16, 1);
    QSPI_INT_RX_FIFO_OVERFLOW_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_TX_FIFO_OVERFLOW_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RX_FIFO_THRESHOLD_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_TX_FIFO_THRESHOLD_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RX_FIFO_NOT_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_TX_FIFO_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_THRESHOLD_LEVEL_RX_THRESHOLD_LEVEL_INITIAL_VALUE: unsigned(4 downto 0) := repeat(x"00", 5, 1);
    QSPI_THRESHOLD_LEVEL_TX_THRESHOLD_LEVEL_INITIAL_VALUE: unsigned(4 downto 0) := repeat(x"00", 5, 1);
    QSPI_STATUS_SPI_BUSY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_STATUS_RX_FIFO_NUM_INITIAL_VALUE: unsigned(4 downto 0) := repeat(x"00", 5, 1);
    QSPI_STATUS_RX_FIFO_FULL_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_STATUS_RX_FIFO_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_STATUS_TX_FIFO_AVAILABLE_INITIAL_VALUE: unsigned(4 downto 0) := repeat(x"00", 5, 1);
    QSPI_STATUS_TX_FIFO_FULL_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_STATUS_TX_FIFO_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RS_RX_FIFO_OVERFLOW_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RS_TX_FIFO_OVERFLOW_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RS_RX_FIFO_THRESHOLD_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RS_TX_FIFO_THRESHOLD_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_RS_TX_FIFO_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_MS_RX_FIFO_OVERFLOW_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_MS_TX_FIFO_OVERFLOW_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_MS_RX_FIFO_THRESHOLD_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_MS_TX_FIFO_THRESHOLD_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_MS_RX_FIFO_NOT_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1);
    QSPI_INT_MS_TX_FIFO_EMPTY_INITIAL_VALUE: unsigned(0 downto 0) := repeat(x"0", 1, 1)
  );
  port (
    i_clk: in std_logic;
    i_rst_n: in std_logic;
    i_awvalid: in std_logic;
    o_awready: out std_logic;
    i_awid: in std_logic_vector(clip_width(ID_WIDTH)-1 downto 0);
    i_awaddr: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    i_awprot: in std_logic_vector(2 downto 0);
    i_wvalid: in std_logic;
    o_wready: out std_logic;
    i_wdata: in std_logic_vector(31 downto 0);
    i_wstrb: in std_logic_vector(3 downto 0);
    o_bvalid: out std_logic;
    i_bready: in std_logic;
    o_bid: out std_logic_vector(clip_width(ID_WIDTH)-1 downto 0);
    o_bresp: out std_logic_vector(1 downto 0);
    i_arvalid: in std_logic;
    o_arready: out std_logic;
    i_arid: in std_logic_vector(clip_width(ID_WIDTH)-1 downto 0);
    i_araddr: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    i_arprot: in std_logic_vector(2 downto 0);
    o_rvalid: out std_logic;
    i_rready: in std_logic;
    o_rid: out std_logic_vector(clip_width(ID_WIDTH)-1 downto 0);
    o_rdata: out std_logic_vector(31 downto 0);
    o_rresp: out std_logic_vector(1 downto 0);
    o_qspi_ctrl_qspi_enable: out std_logic_vector(0 downto 0);
    o_qspi_ctrl_trans_dir: out std_logic_vector(1 downto 0);
    o_qspi_ctrl_protocol_sel: out std_logic_vector(1 downto 0);
    o_qspi_ctrl_word_width: out std_logic_vector(3 downto 0);
    o_qspi_ctrl_spi_slave_en: out std_logic_vector(0 downto 0);
    o_qspi_ctrl_cpha: out std_logic_vector(0 downto 0);
    o_qspi_ctrl_cpol: out std_logic_vector(0 downto 0);
    o_qspi_ctrl_order: out std_logic_vector(0 downto 0);
    o_qspi_ctrl_rx_latch_delay: out std_logic_vector(3 downto 0);
    o_qspi_sw_reset_sw_rst_n: out std_logic_vector(0 downto 0);
    o_qspi_cs_ctrl_cs_manual: out std_logic_vector(0 downto 0);
    o_qspi_cs_ctrl_cs_manual_en: out std_logic_vector(0 downto 0);
    o_qspi_cs_ctrl_cs_sel: out std_logic_vector(1 downto 0);
    o_qspi_master_clk_clk_divisor: out std_logic_vector(15 downto 0);
    o_qspi_data_rx_fifo_clr: out std_logic_vector(0 downto 0);
    o_qspi_data_rx_fifo_clr_write_trigger: out std_logic_vector(0 downto 0);
    o_qspi_data_tx_fifo_clr: out std_logic_vector(0 downto 0);
    o_qspi_data_tx_fifo_clr_write_trigger: out std_logic_vector(0 downto 0);
    o_qspi_data_data: out std_logic_vector(15 downto 0);
    i_qspi_data_data: in std_logic_vector(15 downto 0);
    o_qspi_data_data_write_trigger: out std_logic_vector(0 downto 0);
    o_qspi_data_data_read_trigger: out std_logic_vector(0 downto 0);
    o_qspi_int_rx_fifo_overflow: out std_logic_vector(0 downto 0);
    o_qspi_int_tx_fifo_overflow: out std_logic_vector(0 downto 0);
    o_qspi_int_rx_fifo_threshold: out std_logic_vector(0 downto 0);
    o_qspi_int_tx_fifo_threshold: out std_logic_vector(0 downto 0);
    o_qspi_int_rx_fifo_not_empty: out std_logic_vector(0 downto 0);
    o_qspi_int_tx_fifo_empty: out std_logic_vector(0 downto 0);
    o_qspi_threshold_level_rx_threshold_level: out std_logic_vector(4 downto 0);
    o_qspi_threshold_level_tx_threshold_level: out std_logic_vector(4 downto 0);
    i_qspi_status_spi_busy: in std_logic_vector(0 downto 0);
    i_qspi_status_rx_fifo_num: in std_logic_vector(4 downto 0);
    i_qspi_status_rx_fifo_full: in std_logic_vector(0 downto 0);
    i_qspi_status_rx_fifo_empty: in std_logic_vector(0 downto 0);
    i_qspi_status_tx_fifo_available: in std_logic_vector(4 downto 0);
    i_qspi_status_tx_fifo_full: in std_logic_vector(0 downto 0);
    i_qspi_status_tx_fifo_empty: in std_logic_vector(0 downto 0);
    i_qspi_int_rs_rx_fifo_overflow: in std_logic_vector(0 downto 0);
    i_qspi_int_rs_tx_fifo_overflow: in std_logic_vector(0 downto 0);
    i_qspi_int_rs_rx_fifo_threshold: in std_logic_vector(0 downto 0);
    i_qspi_int_rs_tx_fifo_threshold: in std_logic_vector(0 downto 0);
    i_qspi_int_rs_rx_fifo_not_empty: in std_logic_vector(0 downto 0);
    i_qspi_int_rs_tx_fifo_empty: in std_logic_vector(0 downto 0);
    i_qspi_int_ms_rx_fifo_overflow: in std_logic_vector(0 downto 0);
    o_qspi_int_ms_rx_fifo_overflow_trigger: out std_logic_vector(0 downto 0);
    i_qspi_int_ms_tx_fifo_overflow: in std_logic_vector(0 downto 0);
    o_qspi_int_ms_tx_fifo_overflow_trigger: out std_logic_vector(0 downto 0);
    i_qspi_int_ms_rx_fifo_threshold: in std_logic_vector(0 downto 0);
    o_qspi_int_ms_rx_fifo_threshold_trigger: out std_logic_vector(0 downto 0);
    i_qspi_int_ms_tx_fifo_threshold: in std_logic_vector(0 downto 0);
    o_qspi_int_ms_tx_fifo_threshold_trigger: out std_logic_vector(0 downto 0);
    i_qspi_int_ms_rx_fifo_not_empty: in std_logic_vector(0 downto 0);
    o_qspi_int_ms_rx_fifo_not_empty_trigger: out std_logic_vector(0 downto 0);
    i_qspi_int_ms_tx_fifo_empty: in std_logic_vector(0 downto 0);
    o_qspi_int_ms_tx_fifo_empty_trigger: out std_logic_vector(0 downto 0)
  );
end qspi_axi4lite_slv;

architecture rtl of qspi_axi4lite_slv is
  signal register_valid: std_logic;
  signal register_access: std_logic_vector(1 downto 0);
  signal register_address: std_logic_vector(7 downto 0);
  signal register_write_data: std_logic_vector(31 downto 0);
  signal register_strobe: std_logic_vector(31 downto 0);
  signal register_active: std_logic_vector(9 downto 0);
  signal register_ready: std_logic_vector(9 downto 0);
  signal register_status: std_logic_vector(19 downto 0);
  signal register_read_data: std_logic_vector(319 downto 0);
  signal register_value: std_logic_vector(319 downto 0);
begin
  u_adapter: entity work.rggen_axi4lite_adapter
    generic map (
      ID_WIDTH            => ID_WIDTH,
      ADDRESS_WIDTH       => ADDRESS_WIDTH,
      LOCAL_ADDRESS_WIDTH => 8,
      BUS_WIDTH           => 32,
      REGISTERS           => 10,
      PRE_DECODE          => PRE_DECODE,
      BASE_ADDRESS        => BASE_ADDRESS,
      BYTE_SIZE           => 256,
      ERROR_STATUS        => ERROR_STATUS,
      INSERT_SLICER       => INSERT_SLICER,
      WRITE_FIRST         => WRITE_FIRST
    )
    port map (
      i_clk                 => i_clk,
      i_rst_n               => i_rst_n,
      i_awvalid             => i_awvalid,
      o_awready             => o_awready,
      i_awid                => i_awid,
      i_awaddr              => i_awaddr,
      i_awprot              => i_awprot,
      i_wvalid              => i_wvalid,
      o_wready              => o_wready,
      i_wdata               => i_wdata,
      i_wstrb               => i_wstrb,
      o_bvalid              => o_bvalid,
      i_bready              => i_bready,
      o_bid                 => o_bid,
      o_bresp               => o_bresp,
      i_arvalid             => i_arvalid,
      o_arready             => o_arready,
      i_arid                => i_arid,
      i_araddr              => i_araddr,
      i_arprot              => i_arprot,
      o_rvalid              => o_rvalid,
      i_rready              => i_rready,
      o_rid                 => o_rid,
      o_rdata               => o_rdata,
      o_rresp               => o_rresp,
      o_register_valid      => register_valid,
      o_register_access     => register_access,
      o_register_address    => register_address,
      o_register_write_data => register_write_data,
      o_register_strobe     => register_strobe,
      i_register_active     => register_active,
      i_register_ready      => register_ready,
      i_register_status     => register_status,
      i_register_read_data  => register_read_data
    );
  g_qspi_ctrl: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"f131f331", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"00",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(0),
        o_register_ready        => register_ready(0),
        o_register_status       => register_status(1 downto 0),
        o_register_read_data    => register_read_data(31 downto 0),
        o_register_value        => register_value(31 downto 0),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_qspi_enable: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CTRL_QSPI_ENABLE_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(0 downto 0),
          i_sw_write_data   => bit_field_write_data(0 downto 0),
          o_sw_read_data    => bit_field_read_data(0 downto 0),
          o_sw_value        => bit_field_value(0 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_qspi_enable,
          o_value_unmasked  => open
        );
    end block;
    g_trans_dir: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 2,
          INITIAL_VALUE   => slice(QSPI_CTRL_TRANS_DIR_INITIAL_VALUE, 2, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(5 downto 4),
          i_sw_write_data   => bit_field_write_data(5 downto 4),
          o_sw_read_data    => bit_field_read_data(5 downto 4),
          o_sw_value        => bit_field_value(5 downto 4),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_trans_dir,
          o_value_unmasked  => open
        );
    end block;
    g_protocol_sel: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 2,
          INITIAL_VALUE   => slice(QSPI_CTRL_PROTOCOL_SEL_INITIAL_VALUE, 2, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(9 downto 8),
          i_sw_write_data   => bit_field_write_data(9 downto 8),
          o_sw_read_data    => bit_field_read_data(9 downto 8),
          o_sw_value        => bit_field_value(9 downto 8),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_protocol_sel,
          o_value_unmasked  => open
        );
    end block;
    g_word_width: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 4,
          INITIAL_VALUE   => slice(QSPI_CTRL_WORD_WIDTH_INITIAL_VALUE, 4, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(15 downto 12),
          i_sw_write_data   => bit_field_write_data(15 downto 12),
          o_sw_read_data    => bit_field_read_data(15 downto 12),
          o_sw_value        => bit_field_value(15 downto 12),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_word_width,
          o_value_unmasked  => open
        );
    end block;
    g_spi_slave_en: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CTRL_SPI_SLAVE_EN_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(16 downto 16),
          i_sw_write_data   => bit_field_write_data(16 downto 16),
          o_sw_read_data    => bit_field_read_data(16 downto 16),
          o_sw_value        => bit_field_value(16 downto 16),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_spi_slave_en,
          o_value_unmasked  => open
        );
    end block;
    g_cpha: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CTRL_CPHA_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(20 downto 20),
          i_sw_write_data   => bit_field_write_data(20 downto 20),
          o_sw_read_data    => bit_field_read_data(20 downto 20),
          o_sw_value        => bit_field_value(20 downto 20),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_cpha,
          o_value_unmasked  => open
        );
    end block;
    g_cpol: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CTRL_CPOL_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(21 downto 21),
          i_sw_write_data   => bit_field_write_data(21 downto 21),
          o_sw_read_data    => bit_field_read_data(21 downto 21),
          o_sw_value        => bit_field_value(21 downto 21),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_cpol,
          o_value_unmasked  => open
        );
    end block;
    g_order: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CTRL_ORDER_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(24 downto 24),
          i_sw_write_data   => bit_field_write_data(24 downto 24),
          o_sw_read_data    => bit_field_read_data(24 downto 24),
          o_sw_value        => bit_field_value(24 downto 24),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_order,
          o_value_unmasked  => open
        );
    end block;
    g_rx_latch_delay: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 4,
          INITIAL_VALUE   => slice(QSPI_CTRL_RX_LATCH_DELAY_INITIAL_VALUE, 4, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(31 downto 28),
          i_sw_write_data   => bit_field_write_data(31 downto 28),
          o_sw_read_data    => bit_field_read_data(31 downto 28),
          o_sw_value        => bit_field_value(31 downto 28),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_ctrl_rx_latch_delay,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_sw_reset: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00000001", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"04",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(1),
        o_register_ready        => register_ready(1),
        o_register_status       => register_status(3 downto 2),
        o_register_read_data    => register_read_data(63 downto 32),
        o_register_value        => register_value(63 downto 32),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_sw_rst_n: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_SW_RESET_SW_RST_N_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(0 downto 0),
          i_sw_write_data   => bit_field_write_data(0 downto 0),
          o_sw_read_data    => bit_field_read_data(0 downto 0),
          o_sw_value        => bit_field_value(0 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_sw_reset_sw_rst_n,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_cs_ctrl: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00000113", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"08",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(2),
        o_register_ready        => register_ready(2),
        o_register_status       => register_status(5 downto 4),
        o_register_read_data    => register_read_data(95 downto 64),
        o_register_value        => register_value(95 downto 64),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_cs_manual: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CS_CTRL_CS_MANUAL_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(8 downto 8),
          i_sw_write_data   => bit_field_write_data(8 downto 8),
          o_sw_read_data    => bit_field_read_data(8 downto 8),
          o_sw_value        => bit_field_value(8 downto 8),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_cs_ctrl_cs_manual,
          o_value_unmasked  => open
        );
    end block;
    g_cs_manual_en: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_CS_CTRL_CS_MANUAL_EN_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(4 downto 4),
          i_sw_write_data   => bit_field_write_data(4 downto 4),
          o_sw_read_data    => bit_field_read_data(4 downto 4),
          o_sw_value        => bit_field_value(4 downto 4),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_cs_ctrl_cs_manual_en,
          o_value_unmasked  => open
        );
    end block;
    g_cs_sel: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 2,
          INITIAL_VALUE   => slice(QSPI_CS_CTRL_CS_SEL_INITIAL_VALUE, 2, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(1 downto 0),
          i_sw_write_data   => bit_field_write_data(1 downto 0),
          o_sw_read_data    => bit_field_read_data(1 downto 0),
          o_sw_value        => bit_field_value(1 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_cs_ctrl_cs_sel,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_master_clk: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"0000ffff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"0c",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(3),
        o_register_ready        => register_ready(3),
        o_register_status       => register_status(7 downto 6),
        o_register_read_data    => register_read_data(127 downto 96),
        o_register_value        => register_value(127 downto 96),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_clk_divisor: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 16,
          INITIAL_VALUE   => slice(QSPI_MASTER_CLK_CLK_DIVISOR_INITIAL_VALUE, 16, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(15 downto 0),
          i_sw_write_data   => bit_field_write_data(15 downto 0),
          o_sw_read_data    => bit_field_read_data(15 downto 0),
          o_sw_value        => bit_field_value(15 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_master_clk_clk_divisor,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_data: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"0003ffff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"10",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(4),
        o_register_ready        => register_ready(4),
        o_register_status       => register_status(9 downto 8),
        o_register_read_data    => register_read_data(159 downto 128),
        o_register_value        => register_value(159 downto 128),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_rx_fifo_clr: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_DATA_RX_FIFO_CLR_INITIAL_VALUE, 1, 0),
          SW_READ_ACTION  => RGGEN_READ_NONE,
          SW_WRITE_ONCE   => false,
          TRIGGER         => true
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(17 downto 17),
          i_sw_write_data   => bit_field_write_data(17 downto 17),
          o_sw_read_data    => bit_field_read_data(17 downto 17),
          o_sw_value        => bit_field_value(17 downto 17),
          o_write_trigger   => o_qspi_data_rx_fifo_clr_write_trigger,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_data_rx_fifo_clr,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_clr: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_DATA_TX_FIFO_CLR_INITIAL_VALUE, 1, 0),
          SW_READ_ACTION  => RGGEN_READ_NONE,
          SW_WRITE_ONCE   => false,
          TRIGGER         => true
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(16 downto 16),
          i_sw_write_data   => bit_field_write_data(16 downto 16),
          o_sw_read_data    => bit_field_read_data(16 downto 16),
          o_sw_value        => bit_field_value(16 downto 16),
          o_write_trigger   => o_qspi_data_tx_fifo_clr_write_trigger,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_data_tx_fifo_clr,
          o_value_unmasked  => open
        );
    end block;
    g_data: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 16,
          INITIAL_VALUE       => slice(QSPI_DATA_DATA_INITIAL_VALUE, 16, 0),
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => true
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(15 downto 0),
          i_sw_write_data   => bit_field_write_data(15 downto 0),
          o_sw_read_data    => bit_field_read_data(15 downto 0),
          o_sw_value        => bit_field_value(15 downto 0),
          o_write_trigger   => o_qspi_data_data_write_trigger,
          o_read_trigger    => o_qspi_data_data_read_trigger,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_data_data,
          i_mask            => (others => '1'),
          o_value           => o_qspi_data_data,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_int: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00111111", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"14",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(5),
        o_register_ready        => register_ready(5),
        o_register_status       => register_status(11 downto 10),
        o_register_read_data    => register_read_data(191 downto 160),
        o_register_value        => register_value(191 downto 160),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_rx_fifo_overflow: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_INT_RX_FIFO_OVERFLOW_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(20 downto 20),
          i_sw_write_data   => bit_field_write_data(20 downto 20),
          o_sw_read_data    => bit_field_read_data(20 downto 20),
          o_sw_value        => bit_field_value(20 downto 20),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_int_rx_fifo_overflow,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_overflow: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_INT_TX_FIFO_OVERFLOW_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(16 downto 16),
          i_sw_write_data   => bit_field_write_data(16 downto 16),
          o_sw_read_data    => bit_field_read_data(16 downto 16),
          o_sw_value        => bit_field_value(16 downto 16),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_int_tx_fifo_overflow,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_threshold: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_INT_RX_FIFO_THRESHOLD_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(12 downto 12),
          i_sw_write_data   => bit_field_write_data(12 downto 12),
          o_sw_read_data    => bit_field_read_data(12 downto 12),
          o_sw_value        => bit_field_value(12 downto 12),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_int_rx_fifo_threshold,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_threshold: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_INT_TX_FIFO_THRESHOLD_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(8 downto 8),
          i_sw_write_data   => bit_field_write_data(8 downto 8),
          o_sw_read_data    => bit_field_read_data(8 downto 8),
          o_sw_value        => bit_field_value(8 downto 8),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_int_tx_fifo_threshold,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_not_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_INT_RX_FIFO_NOT_EMPTY_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(4 downto 4),
          i_sw_write_data   => bit_field_write_data(4 downto 4),
          o_sw_read_data    => bit_field_read_data(4 downto 4),
          o_sw_value        => bit_field_value(4 downto 4),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_int_rx_fifo_not_empty,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 1,
          INITIAL_VALUE   => slice(QSPI_INT_TX_FIFO_EMPTY_INITIAL_VALUE, 1, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(0 downto 0),
          i_sw_write_data   => bit_field_write_data(0 downto 0),
          o_sw_read_data    => bit_field_read_data(0 downto 0),
          o_sw_value        => bit_field_value(0 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_int_tx_fifo_empty,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_threshold_level: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00001f1f", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"18",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(6),
        o_register_ready        => register_ready(6),
        o_register_status       => register_status(13 downto 12),
        o_register_read_data    => register_read_data(223 downto 192),
        o_register_value        => register_value(223 downto 192),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_rx_threshold_level: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 5,
          INITIAL_VALUE   => slice(QSPI_THRESHOLD_LEVEL_RX_THRESHOLD_LEVEL_INITIAL_VALUE, 5, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(12 downto 8),
          i_sw_write_data   => bit_field_write_data(12 downto 8),
          o_sw_read_data    => bit_field_read_data(12 downto 8),
          o_sw_value        => bit_field_value(12 downto 8),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_threshold_level_rx_threshold_level,
          o_value_unmasked  => open
        );
    end block;
    g_tx_threshold_level: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 5,
          INITIAL_VALUE   => slice(QSPI_THRESHOLD_LEVEL_TX_THRESHOLD_LEVEL_INITIAL_VALUE, 5, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(4 downto 0),
          i_sw_write_data   => bit_field_write_data(4 downto 0),
          o_sw_read_data    => bit_field_read_data(4 downto 0),
          o_sw_value        => bit_field_value(4 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_qspi_threshold_level_tx_threshold_level,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_status: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"011f31f3", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"1c",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(7),
        o_register_ready        => register_ready(7),
        o_register_status       => register_status(15 downto 14),
        o_register_read_data    => register_read_data(255 downto 224),
        o_register_value        => register_value(255 downto 224),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_spi_busy: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(24 downto 24),
          i_sw_write_data   => bit_field_write_data(24 downto 24),
          o_sw_read_data    => bit_field_read_data(24 downto 24),
          o_sw_value        => bit_field_value(24 downto 24),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_spi_busy,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_num: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 5,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(20 downto 16),
          i_sw_write_data   => bit_field_write_data(20 downto 16),
          o_sw_read_data    => bit_field_read_data(20 downto 16),
          o_sw_value        => bit_field_value(20 downto 16),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_rx_fifo_num,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_full: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(13 downto 13),
          i_sw_write_data   => bit_field_write_data(13 downto 13),
          o_sw_read_data    => bit_field_read_data(13 downto 13),
          o_sw_value        => bit_field_value(13 downto 13),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_rx_fifo_full,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(12 downto 12),
          i_sw_write_data   => bit_field_write_data(12 downto 12),
          o_sw_read_data    => bit_field_read_data(12 downto 12),
          o_sw_value        => bit_field_value(12 downto 12),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_rx_fifo_empty,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_available: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 5,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(8 downto 4),
          i_sw_write_data   => bit_field_write_data(8 downto 4),
          o_sw_read_data    => bit_field_read_data(8 downto 4),
          o_sw_value        => bit_field_value(8 downto 4),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_tx_fifo_available,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_full: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(1 downto 1),
          i_sw_write_data   => bit_field_write_data(1 downto 1),
          o_sw_read_data    => bit_field_read_data(1 downto 1),
          o_sw_value        => bit_field_value(1 downto 1),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_tx_fifo_full,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(0 downto 0),
          i_sw_write_data   => bit_field_write_data(0 downto 0),
          o_sw_read_data    => bit_field_read_data(0 downto 0),
          o_sw_value        => bit_field_value(0 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_status_tx_fifo_empty,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_int_rs: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00111111", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"20",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(8),
        o_register_ready        => register_ready(8),
        o_register_status       => register_status(17 downto 16),
        o_register_read_data    => register_read_data(287 downto 256),
        o_register_value        => register_value(287 downto 256),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_rx_fifo_overflow: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(20 downto 20),
          i_sw_write_data   => bit_field_write_data(20 downto 20),
          o_sw_read_data    => bit_field_read_data(20 downto 20),
          o_sw_value        => bit_field_value(20 downto 20),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_int_rs_rx_fifo_overflow,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_overflow: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(16 downto 16),
          i_sw_write_data   => bit_field_write_data(16 downto 16),
          o_sw_read_data    => bit_field_read_data(16 downto 16),
          o_sw_value        => bit_field_value(16 downto 16),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_int_rs_tx_fifo_overflow,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_threshold: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(12 downto 12),
          i_sw_write_data   => bit_field_write_data(12 downto 12),
          o_sw_read_data    => bit_field_read_data(12 downto 12),
          o_sw_value        => bit_field_value(12 downto 12),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_int_rs_rx_fifo_threshold,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_threshold: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(8 downto 8),
          i_sw_write_data   => bit_field_write_data(8 downto 8),
          o_sw_read_data    => bit_field_read_data(8 downto 8),
          o_sw_value        => bit_field_value(8 downto 8),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_int_rs_tx_fifo_threshold,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_rx_fifo_not_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(4 downto 4),
          i_sw_write_data   => bit_field_write_data(4 downto 4),
          o_sw_read_data    => bit_field_read_data(4 downto 4),
          o_sw_value        => bit_field_value(4 downto 4),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_int_rs_rx_fifo_not_empty,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
    g_tx_fifo_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 1,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "0",
          i_sw_mask         => bit_field_mask(0 downto 0),
          i_sw_write_data   => bit_field_write_data(0 downto 0),
          o_sw_read_data    => bit_field_read_data(0 downto 0),
          o_sw_value        => bit_field_value(0 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_qspi_int_rs_tx_fifo_empty,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_qspi_int_ms: block
    signal bit_field_read_valid: std_logic;
    signal bit_field_write_valid: std_logic;
    signal bit_field_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00111111", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"24",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(9),
        o_register_ready        => register_ready(9),
        o_register_status       => register_status(19 downto 18),
        o_register_read_data    => register_read_data(319 downto 288),
        o_register_value        => register_value(319 downto 288),
        o_bit_field_read_valid  => bit_field_read_valid,
        o_bit_field_write_valid => bit_field_write_valid,
        o_bit_field_mask        => bit_field_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_rx_fifo_overflow: block
    begin
      u_bit_field: entity work.rggen_bit_field_w01trg
        generic map (
          WRITE_ONE_TRIGGER => true,
          WIDTH             => 1
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(20 downto 20),
          i_sw_write_data   => bit_field_write_data(20 downto 20),
          o_sw_read_data    => bit_field_read_data(20 downto 20),
          o_sw_value        => bit_field_value(20 downto 20),
          i_value           => i_qspi_int_ms_rx_fifo_overflow,
          o_trigger         => o_qspi_int_ms_rx_fifo_overflow_trigger
        );
    end block;
    g_tx_fifo_overflow: block
    begin
      u_bit_field: entity work.rggen_bit_field_w01trg
        generic map (
          WRITE_ONE_TRIGGER => true,
          WIDTH             => 1
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(16 downto 16),
          i_sw_write_data   => bit_field_write_data(16 downto 16),
          o_sw_read_data    => bit_field_read_data(16 downto 16),
          o_sw_value        => bit_field_value(16 downto 16),
          i_value           => i_qspi_int_ms_tx_fifo_overflow,
          o_trigger         => o_qspi_int_ms_tx_fifo_overflow_trigger
        );
    end block;
    g_rx_fifo_threshold: block
    begin
      u_bit_field: entity work.rggen_bit_field_w01trg
        generic map (
          WRITE_ONE_TRIGGER => true,
          WIDTH             => 1
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(12 downto 12),
          i_sw_write_data   => bit_field_write_data(12 downto 12),
          o_sw_read_data    => bit_field_read_data(12 downto 12),
          o_sw_value        => bit_field_value(12 downto 12),
          i_value           => i_qspi_int_ms_rx_fifo_threshold,
          o_trigger         => o_qspi_int_ms_rx_fifo_threshold_trigger
        );
    end block;
    g_tx_fifo_threshold: block
    begin
      u_bit_field: entity work.rggen_bit_field_w01trg
        generic map (
          WRITE_ONE_TRIGGER => true,
          WIDTH             => 1
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(8 downto 8),
          i_sw_write_data   => bit_field_write_data(8 downto 8),
          o_sw_read_data    => bit_field_read_data(8 downto 8),
          o_sw_value        => bit_field_value(8 downto 8),
          i_value           => i_qspi_int_ms_tx_fifo_threshold,
          o_trigger         => o_qspi_int_ms_tx_fifo_threshold_trigger
        );
    end block;
    g_rx_fifo_not_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field_w01trg
        generic map (
          WRITE_ONE_TRIGGER => true,
          WIDTH             => 1
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(4 downto 4),
          i_sw_write_data   => bit_field_write_data(4 downto 4),
          o_sw_read_data    => bit_field_read_data(4 downto 4),
          o_sw_value        => bit_field_value(4 downto 4),
          i_value           => i_qspi_int_ms_rx_fifo_not_empty,
          o_trigger         => o_qspi_int_ms_rx_fifo_not_empty_trigger
        );
    end block;
    g_tx_fifo_empty: block
    begin
      u_bit_field: entity work.rggen_bit_field_w01trg
        generic map (
          WRITE_ONE_TRIGGER => true,
          WIDTH             => 1
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_read_valid   => bit_field_read_valid,
          i_sw_write_valid  => bit_field_write_valid,
          i_sw_write_enable => "1",
          i_sw_mask         => bit_field_mask(0 downto 0),
          i_sw_write_data   => bit_field_write_data(0 downto 0),
          o_sw_read_data    => bit_field_read_data(0 downto 0),
          o_sw_value        => bit_field_value(0 downto 0),
          i_value           => i_qspi_int_ms_tx_fifo_empty,
          o_trigger         => o_qspi_int_ms_tx_fifo_empty_trigger
        );
    end block;
  end block;
end rtl;
