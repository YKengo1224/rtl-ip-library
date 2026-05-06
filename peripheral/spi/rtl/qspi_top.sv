//-----------------------------------------------------------------------------
// Title         : QSPI
// Project       : rtl-ip-library
//-----------------------------------------------------------------------------
// File          : qspi_top.sv
// Author        : kengo yanagihara
// Created       : 28.03.2026
// Last modified : 2026/05/06
//-----------------------------------------------------------------------------
// Description :
// QSPI
//-----------------------------------------------------------------------------
// Copyright (c)  Kengo Yanagihara
//
//------------------------------------------------------------------------------
// Modification history:
// 28.03.2026 : created
//-----------------------------------------------------------------------------

`default_nettype none

module qspi_top #(
    parameter int SYNC_FF_DEPTH = 2,
    parameter int ID_WIDTH      = 0,
    parameter int ADDRESS_WIDTH = 16,
    parameter int BUS_WIDTH     = 32,
    parameter int FIFO_SIZE     = 32
) (
    //clk
    input  wire                      aclk,
    input  wire                      sysclk,
    //reset
    input  wire                      aresetn,
    input  wire                      srstn_sysclk,
    //AXI4Lite Signal
    input  wire                      awvalid,
    output logic                     awready,
    input  wire  [     ID_WIDTH-1:0] awid,
    input  wire  [ADDRESS_WIDTH-1:0] awaddr,
    input  wire  [              2:0] awprot,
    input  wire                      wvalid,
    output logic                     wready,
    input  wire  [    BUS_WIDTH-1:0] wdata,
    input  wire  [  BUS_WIDTH/8-1:0] wstrb,
    output logic                     bvalid,
    input  wire                      bready,
    output logic [     ID_WIDTH-1:0] bid,
    output logic [              1:0] bresp,
    input  wire                      arvalid,
    output logic                     arready,
    input  wire  [ADDRESS_WIDTH-1:0] araddr,
    input  wire  [     ID_WIDTH-1:0] arid,
    input  wire  [              2:0] arprot,
    output logic                     rvalid,
    input  wire                      rready,
    output logic [     ID_WIDTH-1:0] rid,
    output logic [              1:0] rresp,
    output logic [    BUS_WIDTH-1:0] rdata,
    //QSPI Signal
    output logic                     qspi_sclk_out_sysclk_o_r,
    output logic                     qspi_sclk_out_en_sysclk_o_r,
    output logic [              3:0] qspi_csn_out_sysclk_o_r,
    output logic [              3:0] qspi_csn_out_en_sysclk_o_r,
    output logic [              3:0] qspi_data_out_sysclk_o_r,
    output logic [              3:0] qspi_data_out_en_sysclk_o_r,
    input  wire                      qspi_sclk_in_i,
    input  wire  [              3:0] qspi_csn_in_i,
    input  wire  [              3:0] qspi_data_in_i,
    //Interrupt Signal
    output wire                      qspi_instr_aclk_o_r
);

    rggen_axi4lite_if #(
        .ID_WIDTH(ID_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) axi4lite_if ();

    logic [$clog2(FIFO_SIZE):0] qspi_status_rx_fifo_num_aclk;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    logic               qspi_cs_ctrl_cs_manual_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_cs_ctrl_cs_manual_en_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_cs_ctrl_cs_manual_en_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_cs_ctrl_cs_manual_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [1:0]         qspi_cs_ctrl_cs_sel_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [1:0]         qspi_cs_ctrl_cs_sel_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    wire [3:0]          qspi_csn_in_sysclk;     // From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_ctrl_cpha_aclk;    // From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_ctrl_cpha_sysclk;  // From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_ctrl_cpol_aclk;    // From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_ctrl_cpol_sysclk;  // From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_ctrl_order_aclk;   // From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_ctrl_order_sysclk; // From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [1:0]         qspi_ctrl_protocol_sel_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [1:0]         qspi_ctrl_protocol_sel_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_ctrl_qspi_enable_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_ctrl_qspi_enable_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [3:0]         qspi_ctrl_rx_latch_delay_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [3:0]         qspi_ctrl_rx_latch_delay_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_ctrl_spi_slave_en_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_ctrl_spi_slave_en_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [1:0]         qspi_ctrl_trans_dir_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [1:0]         qspi_ctrl_trans_dir_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [3:0]         qspi_ctrl_word_width_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [3:0]         qspi_ctrl_word_width_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    wire [3:0]          qspi_data_in_sysclk;    // From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [15:0]        qspi_data_rx_data_aclk; // From rx_fifo of qspi_rx_fifo_async.v
    logic               qspi_data_rx_data_read_trigger_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_data_rx_data_write_trigger_aclk;// From rx_fifo of qspi_rx_fifo_async.v
    logic               qspi_data_rx_fifo_clr_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_data_rx_fifo_clr_write_trigger_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [15:0]        qspi_data_tx_data_aclk; // From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_data_tx_data_write_trigger_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_data_tx_fifo_clr_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_data_tx_fifo_clr_write_trigger_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_rx_fifo_not_empty_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_rx_fifo_not_empty_set_aclk;// From qspi_instr_gen_inst of qspi_instr_gen.v
    logic               qspi_int_ms_rx_fifo_not_empty_unmasked_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_rx_fifo_overflow_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_rx_fifo_overflow_set_aclk;// From qspi_instr_gen_inst of qspi_instr_gen.v
    logic               qspi_int_ms_rx_fifo_overflow_unmasked_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_rx_fifo_threshold_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_rx_fifo_threshold_set_aclk;// From qspi_instr_gen_inst of qspi_instr_gen.v
    logic               qspi_int_ms_rx_fifo_threshold_unmasked_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_tx_fifo_empty_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_tx_fifo_empty_set_aclk;// From qspi_instr_gen_inst of qspi_instr_gen.v
    logic               qspi_int_ms_tx_fifo_empty_unmasked_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_tx_fifo_overflow_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_tx_fifo_overflow_set_aclk;// From qspi_instr_gen_inst of qspi_instr_gen.v
    logic               qspi_int_ms_tx_fifo_overflow_unmasked_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_tx_fifo_threshold_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_ms_tx_fifo_threshold_set_aclk;// From qspi_instr_gen_inst of qspi_instr_gen.v
    logic               qspi_int_ms_tx_fifo_threshold_unmasked_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_rx_fifo_not_empty_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_rx_fifo_overflow_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_rx_fifo_threshold_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_tx_fifo_empty_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_tx_fifo_overflow_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_int_tx_fifo_threshold_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [15:0]        qspi_master_clk_clk_divisor_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [4:0]         qspi_master_clk_clk_divisor_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [15:0]        qspi_rx_fifo_data_in_sysclk;// From qspi_core of qspi_core.v
    logic               qspi_rx_fifo_w_en_sysclk;// From qspi_core of qspi_core.v
    wire                qspi_sclk_in_sysclk;    // From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic               qspi_status_rx_fifo_empty_aclk;// From rx_fifo of qspi_rx_fifo_async.v
    logic               qspi_status_rx_fifo_empty_sysclk;// From rx_fifo of qspi_rx_fifo_async.v
    logic               qspi_status_rx_fifo_full_aclk;// From rx_fifo of qspi_rx_fifo_async.v
    logic               qspi_status_rx_fifo_full_sysclk;// From rx_fifo of qspi_rx_fifo_async.v
    logic               qspi_status_spi_busy_aclk;// From busy_sync of qspi_synchronizer.v
    logic               qspi_status_spi_busy_sysclk;// From qspi_core of qspi_core.v
    logic [$clog2(FIFO_SIZE):0] qspi_status_tx_fifo_available_aclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_status_tx_fifo_empty_aclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_status_tx_fifo_empty_sysclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_status_tx_fifo_full_aclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_status_tx_fifo_full_sysclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_sw_reset_sw_rst_n_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic               qspi_sw_reset_sw_rst_n_sysclk;// From qspi_sync_pclk2sysclk of qspi_sync_pclk2sysclk.v
    logic [4:0]         qspi_threshold_level_rx_threshold_level_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [4:0]         qspi_threshold_level_tx_threshold_level_aclk;// From qspi_axi4lite_slv_inst of qspi_axi4lite_slv.v
    logic [15:0]        qspi_tx_fifo_data_out_sysclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_tx_fifo_data_out_valid_sysclk;// From tx_fifo of qspi_tx_fifo_async.v
    logic               qspi_tx_fifo_r_en_sysclk;// From qspi_core of qspi_core.v
    // End of automatics



    qspi_axi4lite_connector #(
        /*AUTOINSTPARAM*/
                              // Parameters
                              .ID_WIDTH         (ID_WIDTH),
                              .ADDRESS_WIDTH    (ADDRESS_WIDTH),
                              .BUS_WIDTH        (BUS_WIDTH)) qspi_axi4lite_connector_inst (
        .s_axi_if(axi4lite_if),
        /*AUTOINST*/
                                                                                           // Outputs
                                                                                           .awready             (awready),
                                                                                           .wready              (wready),
                                                                                           .bvalid              (bvalid),
                                                                                           .bid                 (bid[ID_WIDTH-1:0]),
                                                                                           .bresp               (bresp[1:0]),
                                                                                           .arready             (arready),
                                                                                           .rvalid              (rvalid),
                                                                                           .rid                 (rid[ID_WIDTH-1:0]),
                                                                                           .rresp               (rresp[1:0]),
                                                                                           .rdata               (rdata[BUS_WIDTH-1:0]),
                                                                                           // Inputs
                                                                                           .awvalid             (awvalid),
                                                                                           .awid                (awid[ID_WIDTH-1:0]),
                                                                                           .awaddr              (awaddr[ADDRESS_WIDTH-1:0]),
                                                                                           .awprot              (awprot[2:0]),
                                                                                           .wvalid              (wvalid),
                                                                                           .wdata               (wdata[BUS_WIDTH-1:0]),
                                                                                           .wstrb               (wstrb[BUS_WIDTH/8-1:0]),
                                                                                           .bready              (bready),
                                                                                           .arvalid             (arvalid),
                                                                                           .araddr              (araddr[ADDRESS_WIDTH-1:0]),
                                                                                           .arid                (arid[ID_WIDTH-1:0]),
                                                                                           .arprot              (arprot[2:0]),
                                                                                           .rready              (rready));


    /*qspi_axi4lite_slv AUTO_TEMPLATE (
     .o_qspi_data_data_write_trigger(qspi_data_tx_data_write_trigger_aclk),
     .o_qspi_data_data (qspi_data_tx_data_aclk[15:0]),
     .o_qspi_data_data_read_trigger(qspi_data_rx_data_read_trigger_aclk),
     .i_qspi_data_data\(.*\) (qspi_data_rx_data\1_aclk[][]),
     .o_\(.*\) (\1_aclk[][]),
     .i_\(.*\) (\1_aclk[][]),
     ) */
    qspi_axi4lite_slv qspi_axi4lite_slv_inst (
        .i_clk(aclk),
        .i_rst_n(aresetn),
        .axi4lite_if(axi4lite_if),
        /*AUTOINST*/
                                              // Outputs
                                              .o_qspi_ctrl_qspi_enable(qspi_ctrl_qspi_enable_aclk), // Templated
                                              .o_qspi_ctrl_trans_dir(qspi_ctrl_trans_dir_aclk[1:0]), // Templated
                                              .o_qspi_ctrl_protocol_sel(qspi_ctrl_protocol_sel_aclk[1:0]), // Templated
                                              .o_qspi_ctrl_word_width(qspi_ctrl_word_width_aclk[3:0]), // Templated
                                              .o_qspi_ctrl_spi_slave_en(qspi_ctrl_spi_slave_en_aclk), // Templated
                                              .o_qspi_ctrl_cpha (qspi_ctrl_cpha_aclk), // Templated
                                              .o_qspi_ctrl_cpol (qspi_ctrl_cpol_aclk), // Templated
                                              .o_qspi_ctrl_order(qspi_ctrl_order_aclk), // Templated
                                              .o_qspi_ctrl_rx_latch_delay(qspi_ctrl_rx_latch_delay_aclk[3:0]), // Templated
                                              .o_qspi_sw_reset_sw_rst_n(qspi_sw_reset_sw_rst_n_aclk), // Templated
                                              .o_qspi_cs_ctrl_cs_manual(qspi_cs_ctrl_cs_manual_aclk), // Templated
                                              .o_qspi_cs_ctrl_cs_manual_en(qspi_cs_ctrl_cs_manual_en_aclk), // Templated
                                              .o_qspi_cs_ctrl_cs_sel(qspi_cs_ctrl_cs_sel_aclk[1:0]), // Templated
                                              .o_qspi_master_clk_clk_divisor(qspi_master_clk_clk_divisor_aclk[15:0]), // Templated
                                              .o_qspi_data_rx_fifo_clr(qspi_data_rx_fifo_clr_aclk), // Templated
                                              .o_qspi_data_rx_fifo_clr_write_trigger(qspi_data_rx_fifo_clr_write_trigger_aclk), // Templated
                                              .o_qspi_data_tx_fifo_clr(qspi_data_tx_fifo_clr_aclk), // Templated
                                              .o_qspi_data_tx_fifo_clr_write_trigger(qspi_data_tx_fifo_clr_write_trigger_aclk), // Templated
                                              .o_qspi_data_data (qspi_data_tx_data_aclk[15:0]), // Templated
                                              .o_qspi_data_data_write_trigger(qspi_data_tx_data_write_trigger_aclk), // Templated
                                              .o_qspi_data_data_read_trigger(qspi_data_rx_data_read_trigger_aclk), // Templated
                                              .o_qspi_int_rx_fifo_overflow(qspi_int_rx_fifo_overflow_aclk), // Templated
                                              .o_qspi_int_tx_fifo_overflow(qspi_int_tx_fifo_overflow_aclk), // Templated
                                              .o_qspi_int_rx_fifo_threshold(qspi_int_rx_fifo_threshold_aclk), // Templated
                                              .o_qspi_int_tx_fifo_threshold(qspi_int_tx_fifo_threshold_aclk), // Templated
                                              .o_qspi_int_rx_fifo_not_empty(qspi_int_rx_fifo_not_empty_aclk), // Templated
                                              .o_qspi_int_tx_fifo_empty(qspi_int_tx_fifo_empty_aclk), // Templated
                                              .o_qspi_threshold_level_rx_threshold_level(qspi_threshold_level_rx_threshold_level_aclk[4:0]), // Templated
                                              .o_qspi_threshold_level_tx_threshold_level(qspi_threshold_level_tx_threshold_level_aclk[4:0]), // Templated
                                              .o_qspi_int_ms_rx_fifo_overflow(qspi_int_ms_rx_fifo_overflow_aclk), // Templated
                                              .o_qspi_int_ms_rx_fifo_overflow_unmasked(qspi_int_ms_rx_fifo_overflow_unmasked_aclk), // Templated
                                              .o_qspi_int_ms_tx_fifo_overflow(qspi_int_ms_tx_fifo_overflow_aclk), // Templated
                                              .o_qspi_int_ms_tx_fifo_overflow_unmasked(qspi_int_ms_tx_fifo_overflow_unmasked_aclk), // Templated
                                              .o_qspi_int_ms_rx_fifo_threshold(qspi_int_ms_rx_fifo_threshold_aclk), // Templated
                                              .o_qspi_int_ms_rx_fifo_threshold_unmasked(qspi_int_ms_rx_fifo_threshold_unmasked_aclk), // Templated
                                              .o_qspi_int_ms_tx_fifo_threshold(qspi_int_ms_tx_fifo_threshold_aclk), // Templated
                                              .o_qspi_int_ms_tx_fifo_threshold_unmasked(qspi_int_ms_tx_fifo_threshold_unmasked_aclk), // Templated
                                              .o_qspi_int_ms_rx_fifo_not_empty(qspi_int_ms_rx_fifo_not_empty_aclk), // Templated
                                              .o_qspi_int_ms_rx_fifo_not_empty_unmasked(qspi_int_ms_rx_fifo_not_empty_unmasked_aclk), // Templated
                                              .o_qspi_int_ms_tx_fifo_empty(qspi_int_ms_tx_fifo_empty_aclk), // Templated
                                              .o_qspi_int_ms_tx_fifo_empty_unmasked(qspi_int_ms_tx_fifo_empty_unmasked_aclk), // Templated
                                              // Inputs
                                              .i_qspi_data_data (qspi_data_rx_data_aclk[15:0]), // Templated
                                              .i_qspi_status_spi_busy(qspi_status_spi_busy_aclk), // Templated
                                              .i_qspi_status_rx_fifo_num(qspi_status_rx_fifo_num_aclk[4:0]), // Templated
                                              .i_qspi_status_rx_fifo_full(qspi_status_rx_fifo_full_aclk), // Templated
                                              .i_qspi_status_rx_fifo_empty(qspi_status_rx_fifo_empty_aclk), // Templated
                                              .i_qspi_status_tx_fifo_available(qspi_status_tx_fifo_available_aclk[4:0]), // Templated
                                              .i_qspi_status_tx_fifo_full(qspi_status_tx_fifo_full_aclk), // Templated
                                              .i_qspi_status_tx_fifo_empty(qspi_status_tx_fifo_empty_aclk), // Templated
                                              .i_qspi_int_ms_rx_fifo_overflow_set(qspi_int_ms_rx_fifo_overflow_set_aclk), // Templated
                                              .i_qspi_int_ms_tx_fifo_overflow_set(qspi_int_ms_tx_fifo_overflow_set_aclk), // Templated
                                              .i_qspi_int_ms_rx_fifo_threshold_set(qspi_int_ms_rx_fifo_threshold_set_aclk), // Templated
                                              .i_qspi_int_ms_tx_fifo_threshold_set(qspi_int_ms_tx_fifo_threshold_set_aclk), // Templated
                                              .i_qspi_int_ms_rx_fifo_not_empty_set(qspi_int_ms_rx_fifo_not_empty_set_aclk), // Templated
                                              .i_qspi_int_ms_tx_fifo_empty_set(qspi_int_ms_tx_fifo_empty_set_aclk)); // Templated


    /* qspi_instr_gen AUTO_TEMPLATE "qspi_instr_gen_inst"(        
        .qspi_instr_aclk_o_r(qspi_instr_aclk_o_r),
        .\(.*\)_i (\1[][]),
        .\(.*\)_o_r (\1[][]),
        );*/
    qspi_instr_gen qspi_instr_gen_inst (
        /*AUTOINST*/
                                        // Outputs
                                        .qspi_int_ms_rx_fifo_overflow_set_aclk_o_r(qspi_int_ms_rx_fifo_overflow_set_aclk), // Templated
                                        .qspi_int_ms_tx_fifo_overflow_set_aclk_o_r(qspi_int_ms_tx_fifo_overflow_set_aclk), // Templated
                                        .qspi_int_ms_rx_fifo_threshold_set_aclk_o_r(qspi_int_ms_rx_fifo_threshold_set_aclk), // Templated
                                        .qspi_int_ms_tx_fifo_threshold_set_aclk_o_r(qspi_int_ms_tx_fifo_threshold_set_aclk), // Templated
                                        .qspi_int_ms_rx_fifo_not_empty_set_aclk_o_r(qspi_int_ms_rx_fifo_not_empty_set_aclk), // Templated
                                        .qspi_int_ms_tx_fifo_empty_set_aclk_o_r(qspi_int_ms_tx_fifo_empty_set_aclk), // Templated
                                        .qspi_instr_aclk_o_r(qspi_instr_aclk_o_r), // Templated
                                        // Inputs
                                        .aclk           (aclk),
                                        .aresetn        (aresetn),
                                        .qspi_status_tx_fifo_empty_aclk_i(qspi_status_tx_fifo_empty_aclk), // Templated
                                        .qspi_status_tx_fifo_full_aclk_i(qspi_status_tx_fifo_full_aclk), // Templated
                                        .qspi_status_tx_fifo_available_aclk_i(qspi_status_tx_fifo_available_aclk[$clog2(FIFO_SIZE):0]), // Templated
                                        .qspi_status_rx_fifo_empty_aclk_i(qspi_status_rx_fifo_empty_aclk), // Templated
                                        .qspi_status_rx_fifo_full_aclk_i(qspi_status_rx_fifo_full_aclk), // Templated
                                        .qspi_status_rx_fifo_num_aclk_i(qspi_status_rx_fifo_num_aclk[$clog2(FIFO_SIZE):0]), // Templated
                                        .qspi_data_tx_data_write_trigger_aclk_i(qspi_data_tx_data_write_trigger_aclk), // Templated
                                        .qspi_data_rx_data_write_trigger_aclk_i(qspi_data_rx_data_write_trigger_aclk), // Templated
                                        .qspi_int_rx_fifo_overflow_aclk_i(qspi_int_rx_fifo_overflow_aclk), // Templated
                                        .qspi_int_tx_fifo_overflow_aclk_i(qspi_int_tx_fifo_overflow_aclk), // Templated
                                        .qspi_int_rx_fifo_threshold_aclk_i(qspi_int_rx_fifo_threshold_aclk), // Templated
                                        .qspi_int_tx_fifo_threshold_aclk_i(qspi_int_tx_fifo_threshold_aclk), // Templated
                                        .qspi_int_rx_fifo_not_empty_aclk_i(qspi_int_rx_fifo_not_empty_aclk), // Templated
                                        .qspi_int_tx_fifo_empty_aclk_i(qspi_int_tx_fifo_empty_aclk), // Templated
                                        .qspi_threshold_level_rx_threshold_level_aclk_i(qspi_threshold_level_rx_threshold_level_aclk[4:0]), // Templated
                                        .qspi_threshold_level_tx_threshold_level_aclk_i(qspi_threshold_level_tx_threshold_level_aclk[4:0])); // Templated


    /* qspi_tx_fifo_async AUTO_TEMPLATE "tx_fifo" (
        .wclk         (aclk),
        .rst_n_wclk   (aresetn),
        .rclk         (sysclk),
        .rst_n_rclk   (srstn_sysclk),     
        .w_en_wclk    (qspi_data_tx_data_write_trigger_aclk),
        .data_in_wclk (qspi_data_tx_data_aclk[15:0]),
        .data_out_rclkr (qspi_tx_fifo_data_out_sysclk[15:0]),
        .data_out_valid_rclkr(qspi_tx_fifo_data_out_valid_sysclk),
        .r_en_rclk (qspi_tx_fifo_r_en_sysclk),
     
     
        .\(.*\)_wclkr (qspi_status_tx_fifo_\1_aclk[][]),
        .\(.*\)_rclkr (qspi_status_tx_fifo_\1_sysclk[][]),
    ); */
    qspi_tx_fifo_async #(
        .BITWIDTH(16),
        .FIFO_SIZE(FIFO_SIZE),  //only 2**n
        .SYNC_FF_DEPTH(2),
        .ALMOST_FULL_SIZE(FIFO_SIZE - 4),
        .ALMOST_EMPTY_SIZE(4)
    ) tx_fifo (
        /*AUTOINST*/
               // Outputs
               .data_out_rclkr  (qspi_tx_fifo_data_out_sysclk[15:0]), // Templated
               .data_out_valid_rclkr(qspi_tx_fifo_data_out_valid_sysclk), // Templated
               .empty_wclkr     (qspi_status_tx_fifo_empty_aclk), // Templated
               .full_wclkr      (qspi_status_tx_fifo_full_aclk), // Templated
               .available_wclkr (qspi_status_tx_fifo_available_aclk[$clog2(FIFO_SIZE):0]), // Templated
               .empty_rclkr     (qspi_status_tx_fifo_empty_sysclk), // Templated
               .full_rclkr      (qspi_status_tx_fifo_full_sysclk), // Templated
               // Inputs
               .wclk            (aclk),                  // Templated
               .rclk            (sysclk),                // Templated
               .rst_n_wclk      (aresetn),               // Templated
               .rst_n_rclk      (srstn_sysclk),          // Templated
               .w_en_wclk       (qspi_data_tx_data_write_trigger_aclk), // Templated
               .data_in_wclk    (qspi_data_tx_data_aclk[15:0]), // Templated
               .r_en_rclk       (qspi_tx_fifo_r_en_sysclk)); // Templated

    /* qspi_rx_fifo_async AUTO_TEMPLATE "rx_fifo" (
        .wclk         (sysclk),
        .rst_n_wclk   (srstn_sysclk),
        .rclk         (aclk),
        .rst_n_rclk   (aresetn),     
        .r_en_rclk (qspi_data_rx_data_read_trigger_aclk),                   
        .data_in_wclk(qspi_rx_fifo_data_in_sysclk),
        .data_out_rclkr (qspi_data_rx_data_aclk[15:0]),
        .w_en_wclk (qspi_rx_fifo_w_en_sysclk),
        .w_en_rclkr(qspi_data_rx_data_write_trigger_aclk),
        .fifo_num_rclk   (qspi_status_rx_fifo_num_aclk[$clog2(FIFO_SIZE):0]),
     
        .\(.*\)_wclk (qspi_status_rx_fifo_\1_sysclk[][]), 
        .\(.*\)_rclk (qspi_status_rx_fifo_\1_aclk[][]),       
        .\(.*\)_wclkr (qspi_status_rx_fifo_\1_sysclk[][]),     
        .\(.*\)_rclkr (qspi_status_rx_fifo_\1_aclk[][]),
         
    ); */

    qspi_rx_fifo_async #(
        .BITWIDTH(16),
        .FIFO_SIZE(FIFO_SIZE),  //only 2**n
        .SYNC_FF_DEPTH(2),
        .ALMOST_FULL_SIZE(FIFO_SIZE - 4),
        .ALMOST_EMPTY_SIZE(4)
    ) rx_fifo (
        /*AUTOINST*/
               // Outputs
               .data_out_rclkr  (qspi_data_rx_data_aclk[15:0]), // Templated
               .empty_wclkr     (qspi_status_rx_fifo_empty_sysclk), // Templated
               .full_wclkr      (qspi_status_rx_fifo_full_sysclk), // Templated
               .w_en_rclkr      (qspi_data_rx_data_write_trigger_aclk), // Templated
               .empty_rclkr     (qspi_status_rx_fifo_empty_aclk), // Templated
               .full_rclkr      (qspi_status_rx_fifo_full_aclk), // Templated
               .fifo_num_rclk   (qspi_status_rx_fifo_num_aclk[$clog2(FIFO_SIZE):0]), // Templated
               // Inputs
               .wclk            (sysclk),                // Templated
               .rclk            (aclk),                  // Templated
               .rst_n_wclk      (srstn_sysclk),          // Templated
               .rst_n_rclk      (aresetn),               // Templated
               .w_en_wclk       (qspi_rx_fifo_w_en_sysclk), // Templated
               .data_in_wclk    (qspi_rx_fifo_data_in_sysclk), // Templated
               .r_en_rclk       (qspi_data_rx_data_read_trigger_aclk)); // Templated

    /* qspi_sync_pclk2sysclk AUTO_TEMPLATE "qspi_sync_pclk2sysclk" (        
        .qspi_sclk_in_i        (qspi_sclk_in_i),
        .qspi_csn_in_i         (qspi_csn_in_i[3:0]),
        .qspi_data_in_i        (qspi_data_in_i[3:0]),
        .\(.*\)_i (\1[][]), 
        .\(.*\)_o (\1[][]),
         
    ); */
    qspi_sync_pclk2sysclk qspi_sync_pclk2sysclk (
        /*AUTOINST*/
                                                 // Outputs
                                                 .qspi_sclk_in_sysclk_o (qspi_sclk_in_sysclk), // Templated
                                                 .qspi_csn_in_sysclk_o  (qspi_csn_in_sysclk[3:0]), // Templated
                                                 .qspi_data_in_sysclk_o (qspi_data_in_sysclk[3:0]), // Templated
                                                 .qspi_ctrl_qspi_enable_sysclk_o(qspi_ctrl_qspi_enable_sysclk), // Templated
                                                 .qspi_ctrl_trans_dir_sysclk_o(qspi_ctrl_trans_dir_sysclk[1:0]), // Templated
                                                 .qspi_ctrl_protocol_sel_sysclk_o(qspi_ctrl_protocol_sel_sysclk[1:0]), // Templated
                                                 .qspi_ctrl_word_width_sysclk_o(qspi_ctrl_word_width_sysclk[3:0]), // Templated
                                                 .qspi_ctrl_spi_slave_en_sysclk_o(qspi_ctrl_spi_slave_en_sysclk), // Templated
                                                 .qspi_ctrl_cpol_sysclk_o(qspi_ctrl_cpol_sysclk), // Templated
                                                 .qspi_ctrl_cpha_sysclk_o(qspi_ctrl_cpha_sysclk), // Templated
                                                 .qspi_ctrl_order_sysclk_o(qspi_ctrl_order_sysclk), // Templated
                                                 .qspi_ctrl_rx_latch_delay_sysclk_o(qspi_ctrl_rx_latch_delay_sysclk[3:0]), // Templated
                                                 .qspi_sw_reset_sw_rst_n_sysclk_o(qspi_sw_reset_sw_rst_n_sysclk), // Templated
                                                 .qspi_cs_ctrl_cs_manual_sysclk_o(qspi_cs_ctrl_cs_manual_sysclk), // Templated
                                                 .qspi_cs_ctrl_cs_manual_en_sysclk_o(qspi_cs_ctrl_cs_manual_en_sysclk), // Templated
                                                 .qspi_cs_ctrl_cs_sel_sysclk_o(qspi_cs_ctrl_cs_sel_sysclk[1:0]), // Templated
                                                 .qspi_master_clk_clk_divisor_sysclk_o(qspi_master_clk_clk_divisor_sysclk[4:0]), // Templated
                                                 // Inputs
                                                 .aclk                  (aclk),
                                                 .sysclk                (sysclk),
                                                 .aresetn               (aresetn),
                                                 .srstn_sysclk          (srstn_sysclk),
                                                 .qspi_sclk_in_i        (qspi_sclk_in_i), // Templated
                                                 .qspi_csn_in_i         (qspi_csn_in_i[3:0]), // Templated
                                                 .qspi_data_in_i        (qspi_data_in_i[3:0]), // Templated
                                                 .qspi_ctrl_qspi_enable_aclk_i(qspi_ctrl_qspi_enable_aclk), // Templated
                                                 .qspi_ctrl_trans_dir_aclk_i(qspi_ctrl_trans_dir_aclk[1:0]), // Templated
                                                 .qspi_ctrl_protocol_sel_aclk_i(qspi_ctrl_protocol_sel_aclk[1:0]), // Templated
                                                 .qspi_ctrl_word_width_aclk_i(qspi_ctrl_word_width_aclk[3:0]), // Templated
                                                 .qspi_ctrl_spi_slave_en_aclk_i(qspi_ctrl_spi_slave_en_aclk), // Templated
                                                 .qspi_ctrl_cpol_aclk_i (qspi_ctrl_cpol_aclk), // Templated
                                                 .qspi_ctrl_cpha_aclk_i (qspi_ctrl_cpha_aclk), // Templated
                                                 .qspi_ctrl_order_aclk_i(qspi_ctrl_order_aclk), // Templated
                                                 .qspi_ctrl_rx_latch_delay_aclk_i(qspi_ctrl_rx_latch_delay_aclk[3:0]), // Templated
                                                 .qspi_sw_reset_sw_rst_n_aclk_i(qspi_sw_reset_sw_rst_n_aclk), // Templated
                                                 .qspi_cs_ctrl_cs_manual_aclk_i(qspi_cs_ctrl_cs_manual_aclk), // Templated
                                                 .qspi_cs_ctrl_cs_manual_en_aclk_i(qspi_cs_ctrl_cs_manual_en_aclk), // Templated
                                                 .qspi_cs_ctrl_cs_sel_aclk_i(qspi_cs_ctrl_cs_sel_aclk[1:0]), // Templated
                                                 .qspi_master_clk_clk_divisor_aclk_i(qspi_master_clk_clk_divisor_aclk[4:0])); // Templated

    /* qspi_synchronizer AUTO_TEMPLATE "busy_sync" (        
        .CLK(aclk),
        .RST_N(aresetn),
        .DATA_IN(qspi_status_spi_busy_sysclk),
        .DATA_OUT(qspi_status_spi_busy_aclk),
         
    ); */
    qspi_synchronizer #(
        .FF_DEPTH(SYNC_FF_DEPTH)
    ) busy_sync (
        /*AUTOINST*/
                 // Outputs
                 .DATA_OUT              (qspi_status_spi_busy_aclk), // Templated
                 // Inputs
                 .CLK                   (aclk),                  // Templated
                 .RST_N                 (aresetn),               // Templated
                 .DATA_IN               (qspi_status_spi_busy_sysclk)); // Templated


    /* qspi_core AUTO_TEMPLATE "qspi_core" (             
        .\(.*\)_i (\1[][]),       
        .\(.*\)_o_r (\1[][]),
        .qspi_sclk_out_sysclk_o_r(qspi_sclk_out_sysclk_o_r),
        .qspi_sclk_out_en_sysclk_o_r(qspi_sclk_out_en_sysclk_o_r),
        .qspi_csn_out_sysclk_o_r(qspi_csn_out_sysclk_o_r),
        .qspi_csn_out_en_sysclk_o_r(qspi_csn_out_en_sysclk_o_r),
        .qspi_data_out_sysclk_o_r(qspi_data_out_sysclk_o_r),
        .qspi_data_out_en_sysclk_o_r(qspi_data_out_en_sysclk_o_r),
    ); */
    qspi_core #(
        .SYNC_FF_DEPTH(SYNC_FF_DEPTH)
    ) qspi_core (
        /*AUTOINST*/
                 // Outputs
                 .qspi_status_spi_busy_sysclk_o_r(qspi_status_spi_busy_sysclk), // Templated
                 .qspi_tx_fifo_r_en_sysclk_o_r(qspi_tx_fifo_r_en_sysclk), // Templated
                 .qspi_rx_fifo_w_en_sysclk_o_r(qspi_rx_fifo_w_en_sysclk), // Templated
                 .qspi_rx_fifo_data_in_sysclk_o_r(qspi_rx_fifo_data_in_sysclk[15:0]), // Templated
                 .qspi_sclk_out_sysclk_o_r(qspi_sclk_out_sysclk_o_r), // Templated
                 .qspi_sclk_out_en_sysclk_o_r(qspi_sclk_out_en_sysclk_o_r), // Templated
                 .qspi_csn_out_sysclk_o_r(qspi_csn_out_sysclk_o_r), // Templated
                 .qspi_csn_out_en_sysclk_o_r(qspi_csn_out_en_sysclk_o_r), // Templated
                 .qspi_data_out_sysclk_o_r(qspi_data_out_sysclk_o_r), // Templated
                 .qspi_data_out_en_sysclk_o_r(qspi_data_out_en_sysclk_o_r), // Templated
                 // Inputs
                 .sysclk                (sysclk),
                 .srstn_sysclk          (srstn_sysclk),
                 .qspi_ctrl_qspi_enable_sysclk_i(qspi_ctrl_qspi_enable_sysclk), // Templated
                 .qspi_ctrl_trans_dir_sysclk_i(qspi_ctrl_trans_dir_sysclk[1:0]), // Templated
                 .qspi_ctrl_protocol_sel_sysclk_i(qspi_ctrl_protocol_sel_sysclk[1:0]), // Templated
                 .qspi_ctrl_word_width_sysclk_i(qspi_ctrl_word_width_sysclk[3:0]), // Templated
                 .qspi_ctrl_spi_slave_en_sysclk_i(qspi_ctrl_spi_slave_en_sysclk), // Templated
                 .qspi_ctrl_cpol_sysclk_i(qspi_ctrl_cpol_sysclk), // Templated
                 .qspi_ctrl_cpha_sysclk_i(qspi_ctrl_cpha_sysclk), // Templated
                 .qspi_ctrl_order_sysclk_i(qspi_ctrl_order_sysclk), // Templated
                 .qspi_ctrl_rx_latch_delay_sysclk_i(qspi_ctrl_rx_latch_delay_sysclk[3:0]), // Templated
                 .qspi_sw_reset_sw_rst_n_sysclk_i(qspi_sw_reset_sw_rst_n_sysclk), // Templated
                 .qspi_cs_ctrl_cs_manual_sysclk_i(qspi_cs_ctrl_cs_manual_sysclk), // Templated
                 .qspi_cs_ctrl_cs_manual_en_sysclk_i(qspi_cs_ctrl_cs_manual_en_sysclk), // Templated
                 .qspi_cs_ctrl_cs_sel_sysclk_i(qspi_cs_ctrl_cs_sel_sysclk[1:0]), // Templated
                 .qspi_master_clk_clk_divisor_sysclk_i(qspi_master_clk_clk_divisor_sysclk[4:0]), // Templated
                 .qspi_status_tx_fifo_full_sysclk_i(qspi_status_tx_fifo_full_sysclk), // Templated
                 .qspi_status_tx_fifo_empty_sysclk_i(qspi_status_tx_fifo_empty_sysclk), // Templated
                 .qspi_tx_fifo_data_out_sysclk_i(qspi_tx_fifo_data_out_sysclk[15:0]), // Templated
                 .qspi_tx_fifo_data_out_valid_sysclk_i(qspi_tx_fifo_data_out_valid_sysclk), // Templated
                 .qspi_status_rx_fifo_full_sysclk_i(qspi_status_rx_fifo_full_sysclk), // Templated
                 .qspi_status_rx_fifo_empty_sysclk_i(qspi_status_rx_fifo_empty_sysclk), // Templated
                 .qspi_sclk_in_sysclk_i (qspi_sclk_in_sysclk),   // Templated
                 .qspi_csn_in_sysclk_i  (qspi_csn_in_sysclk[3:0]), // Templated
                 .qspi_data_in_sysclk_i (qspi_data_in_sysclk[3:0])); // Templated



endmodule

`default_nettype wire
// Local Variables:
// verilog-library-directories:("./" "./regfile_rggen/out")
// verilog-auto-inst-column:24  ;; Min. 24?
// indent-tabs-mode:nil
// End:
