`timescale 1ns/1ps
`ifndef _H_CASE_PKG_SV
`define _H_CASE_PKG_SV

package case_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import validation packages
    import axi4lite_pkg::*;
    import uart_bfm_pkg::*;
    import uart_val_pkg::*;

    // Include base helper
    `include "uart_test_case_helper.sv"

    // Include manually written sequences
    `include "uart_tx_sample_seq.sv"
    `include "sample_ral_seq.sv"
    `include "test_reg_access_basic.sv"
    `include "test_reg_access_consecutive_read.sv"
    `include "test_reg_access_alternate_rw.sv"
    `include "test_tx_normal.sv"
    `include "test_rx_normal.sv"

    // Include automatically generated sequences
    `include "test_rtx_baudrate_110.sv"
    `include "test_rtx_baudrate_300.sv"
    `include "test_rtx_baudrate_600.sv"
    `include "test_rtx_baudrate_1200.sv"
    `include "test_rtx_baudrate_2400.sv"
    `include "test_rtx_baudrate_4800.sv"
    `include "test_rtx_baudrate_9600.sv"
    `include "test_rtx_baudrate_19200.sv"
    `include "test_rtx_baudrate_38400.sv"
    `include "test_rtx_baudrate_57600.sv"
    `include "test_rtx_baudrate_230400.sv"
    `include "test_rtx_baudrate_460800.sv"
    `include "test_rtx_baudrate_921600.sv"
    `include "test_rtx_databit_5.sv"
    `include "test_rtx_databit_6.sv"
    `include "test_rtx_databit_7.sv"
    `include "test_rtx_databit_9.sv"
    `include "test_rtx_stopbit_0_5.sv"
    `include "test_rtx_stopbit_1_5.sv"
    `include "test_rtx_stopbit_2.sv"
    `include "test_rtx_parity_odd.sv"
    `include "test_rtx_parity_even.sv"
    `include "test_tx_flow_cts.sv"
    `include "test_rx_flow_rts.sv"
    `include "test_tx_fifo_full_protect.sv"
    `include "test_rx_fifo_empty_read.sv"
    `include "test_rx_parity_error.sv"
    `include "test_rx_framing_error.sv"
    `include "test_rx_overrun_error.sv"
    `include "test_rx_break_detect.sv"
    `include "test_rx_timeout.sv"
    `include "test_rx_timeout_clear.sv"
    `include "test_tx_fifo_threshold.sv"
    `include "test_rx_fifo_threshold.sv"
    `include "test_tx_polarity_inv.sv"
    `include "test_rx_polarity_inv.sv"
    `include "test_polarity_mismatch.sv"
    `include "test_uart_disable_mid_transfer.sv"
    `include "test_tx_break_send.sv"
    `include "test_async_reset_active.sv"
    `include "test_over_samp_8.sv"
    `include "test_over_samp_32.sv"
    `include "test_samp_num_3_normal.sv"
    `include "test_samp_num_3_noise_filter.sv"
    `include "test_samp_num_1_noise_error.sv"
    `include "test_tx_th_level_min.sv"
    `include "test_tx_th_level_max.sv"
    `include "test_rx_th_level_min.sv"
    `include "test_rx_th_level_max.sv"
    `include "test_th_level_dynamic_change.sv"
    `include "test_tx_fifo_limit_burst.sv"
    `include "test_rx_fifo_limit_burst.sv"
    `include "test_duplex_fifo_limit_burst.sv"

endpackage

`endif
