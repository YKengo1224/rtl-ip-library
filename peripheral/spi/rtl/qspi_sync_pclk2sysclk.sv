//-----------------------------------------------------------------------------
// Title         : QSPI
// Project       : rtl-ip-library
//-----------------------------------------------------------------------------
// File          : qspi_sync_pclk2sysclk.sv
// Author        : kengo yanagihara  <kengo@sirotan>
// Created       : 04.04.2026
// Last modified : 2026/04/11
//-----------------------------------------------------------------------------
// Description :
// QSPI syncronizer 
//-----------------------------------------------------------------------------
// Copyright (c) 2026 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 04.04.2026 : created
//-----------------------------------------------------------------------------



`default_nettype none

module qspi_sync_pclk2sysclk #(
    parameter int SYNC_FF_DEPTH = 2
) (

    input wire aclk,
    input wire sysclk,
    input wire aresetn,
    input wire srstn_sysclk,

    input wire       qspi_sclk_in_i,
    input wire [3:0] qspi_csn_in_i,
    input wire [3:0] qspi_data_in_i,

    input wire        qspi_ctrl_qspi_enable_aclk_i,
    input wire [ 1:0] qspi_ctrl_trans_dir_aclk_i,
    input wire [ 1:0] qspi_ctrl_protocol_sel_aclk_i,
    input wire [ 3:0] qspi_ctrl_word_width_aclk_i,
    input wire        qspi_ctrl_spi_slave_en_aclk_i,
    input wire        qspi_ctrl_cpol_aclk_i,
    input wire        qspi_ctrl_cpha_aclk_i,
    input wire        qspi_ctrl_order_aclk_i,
    input wire [ 3:0] qspi_ctrl_rx_latch_delay_aclk_i,
    input wire        qspi_sw_reset_sw_rst_n_aclk_i,
    input wire        qspi_cs_ctrl_cs_manual_aclk_i,
    input wire        qspi_cs_ctrl_cs_manual_en_aclk_i,
    input wire [ 1:0] qspi_cs_ctrl_cs_sel_aclk_i,
    input wire [15:0] qspi_master_clk_clk_divisor_aclk_i,

    output wire       qspi_sclk_in_sysclk_o,
    output wire [3:0] qspi_csn_in_sysclk_o,
    output wire [3:0] qspi_data_in_sysclk_o,

    output logic        qspi_ctrl_qspi_enable_sysclk_o,
    output logic [ 1:0] qspi_ctrl_trans_dir_sysclk_o,
    output logic [ 1:0] qspi_ctrl_protocol_sel_sysclk_o,
    output logic [ 3:0] qspi_ctrl_word_width_sysclk_o,
    output logic        qspi_ctrl_spi_slave_en_sysclk_o,
    output logic        qspi_ctrl_cpol_sysclk_o,
    output logic        qspi_ctrl_cpha_sysclk_o,
    output logic        qspi_ctrl_order_sysclk_o,
    output logic [ 3:0] qspi_ctrl_rx_latch_delay_sysclk_o,
    output logic        qspi_sw_reset_sw_rst_n_sysclk_o,
    output logic        qspi_cs_ctrl_cs_manual_sysclk_o,
    output logic        qspi_cs_ctrl_cs_manual_en_sysclk_o,
    output logic [ 1:0] qspi_cs_ctrl_cs_sel_sysclk_o,
    output logic [15:0] qspi_master_clk_clk_divisor_sysclk_o
);

    wire [46:0] data_aclk;
    wire [46:0] data_sysclk;


    assign data_aclk = {
        qspi_sclk_in_i,
        qspi_csn_in_i,
        qspi_data_in_i,
        qspi_ctrl_qspi_enable_aclk_i,
        qspi_ctrl_trans_dir_aclk_i,
        qspi_ctrl_protocol_sel_aclk_i,
        qspi_ctrl_word_width_aclk_i,
        qspi_ctrl_spi_slave_en_aclk_i,
        qspi_ctrl_cpol_aclk_i,
        qspi_ctrl_cpha_aclk_i,
        qspi_ctrl_order_aclk_i,
        qspi_ctrl_rx_latch_delay_aclk_i,
        qspi_sw_reset_sw_rst_n_aclk_i,
        qspi_cs_ctrl_cs_manual_aclk_i,
        qspi_cs_ctrl_cs_manual_en_aclk_i,
        qspi_cs_ctrl_cs_sel_aclk_i,
        qspi_master_clk_clk_divisor_aclk_i
    };



    assign {
        qspi_sclk_in_sysclk_o,
        qspi_csn_in_sysclk_o,
        qspi_data_in_sysclk_o,
        qspi_ctrl_qspi_enable_sysclk_o,
        qspi_ctrl_trans_dir_sysclk_o,
        qspi_ctrl_protocol_sel_sysclk_o,
        qspi_ctrl_word_width_sysclk_o,
        qspi_ctrl_spi_slave_en_sysclk_o,
        qspi_ctrl_cpol_sysclk_o,
        qspi_ctrl_cpha_sysclk_o,
        qspi_ctrl_order_sysclk_o,
        qspi_ctrl_rx_latch_delay_sysclk_o,
        qspi_sw_reset_sw_rst_n_sysclk_o,
        qspi_cs_ctrl_cs_manual_sysclk_o,
        qspi_cs_ctrl_cs_manual_en_sysclk_o,
        qspi_cs_ctrl_cs_sel_sysclk_o,
        qspi_master_clk_clk_divisor_sysclk_o
    }= data_sysclk;

    genvar gi;
    generate
        for (gi = 0; gi < 47; gi++) begin : gen_sync
            synchronizer #(
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) aclk2sysclk_synchronizer (
                .CLK(wclk),
                .RST_N(rst_n_wclk),
                .DATA_IN(data_aclk),
                .DATA_OUT(data_sysclk)
            );
        end
    endgenerate
endmodule


`default_nettype wire
