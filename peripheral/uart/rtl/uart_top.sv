`default_nettype none
module uart_top #(
    parameter int ADDR_BITWIDTH = 32,
    parameter int DATA_BITWIDTH = 32,
    parameter int VARID_ADDR_BITWIDTH = 8
) (
    input  wire                          aclk,
    input  wire                          aresetn,
    input  wire                          sysclk,
    input  wire                          sysrst_n,
    //====================================================
    // AXI4-Lite Ports
    //====================================================
    //AW Channel
    input  wire  [   ADDR_BITWIDTH -1:0] awaddr,
    input  wire                          awprot,
    input  wire                          awvalid,
    output logic                         awready,
    //W Channel
    input  wire  [   DATA_BITWIDTH -1:0] wdata,
    input  wire  [(ADDR_BITWIDTH/8)-1:0] wstrb,
    input  wire                          wvalid,
    output logic                         wready,
    //B Channel
    output reg   [                  1:0] bresp,
    output reg                           bvalid,
    input  wire                          bready,
    //AR Channel
    input  wire  [   ADDR_BITWIDTH -1:0] araddr,
    input  wire                          arprot,
    input  wire                          arvalid,
    output reg                           arready,
    //R Channel
    output reg   [   DATA_BITWIDTH -1:0] rdata,
    output logic [                  1:0] rresp,
    output reg                           rvalid,
    input  wire                          rready,
    //====================================================
    // UART Signals
    //====================================================
    output logic                         o_uart_txd_sysclkr,
    input  wire                          i_uart_rxd,
    output logic                         o_uart_rts_sysclkr,
    input  wire                          i_uart_ctsn,
    //====================================================
    // Interuppt
    //====================================================
    output wire                          o_interrupt_aclkr
);

    wire uart_rxd_sysclk;
    wire uart_ctsn_sysclk;


    //=========================================
    // Auto Wire Declarations (Emacs verilog-mode)
    //=========================================
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire break_det_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire break_send_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire break_send_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire [15:0] conf_clk_div_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [15:0] conf_clk_div_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire [3:0] conf_data_bit_width_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [3:0] conf_data_bit_width_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire conf_hw_flow_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire conf_hw_flow_en_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire [1:0] conf_over_samp_sel_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [1:0] conf_over_samp_sel_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire [1:0] conf_parity_bit_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [1:0] conf_parity_bit_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire conf_rx_inv_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire conf_rx_inv_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire conf_samp_num_sel_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire conf_samp_num_sel_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire [1:0] conf_stop_bit_width_sel_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [1:0]          conf_stop_bit_width_sel_sysclk;// From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire conf_tx_inv_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire conf_tx_inv_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire int_break_det_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_break_det_raw_set_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire int_framing_err_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_framing_err_raw_se_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire int_overrun_err_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_overrun_err_raw_set_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire int_parity_err_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_parity_err_raw_set_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire int_rx_fifo_th_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_rx_fifo_th_raw_set_aclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire int_rx_timeout_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_rx_timeout_raw_set_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire int_tx_fifo_th_en_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire int_tx_fifo_th_raw_set_aclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire interrupt_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire over_samp_clken_sysclk;  // From uart_clk_divider of uart_clk_divider.v
    wire rx_busy_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire rx_busy_sysclk;  // From uart_rx of uart_rx.v
    wire rx_detect_break_sysclk;  // From uart_rx of uart_rx.v
    wire rx_detect_timeout_tirg_sysclk;  // From uart_rx of uart_rx.v
    wire rx_fifo_almost_empty_aclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_almost_empty_sysclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_almost_full_aclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_almost_full_sysclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_empty_aclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_empty_sysclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_full_aclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire rx_fifo_full_sysclk;  // From uart_rx_fifo_async of uart_rx_fifo_async.v
    wire [4:0] rx_fifo_th_level_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [8:0] rx_fifo_wdata_sysclk;  // From uart_rx of uart_rx.v
    wire rx_fifo_wen_sysclk;  // From uart_rx of uart_rx.v
    wire rx_framing_err_trig_sysclk;  // From uart_rx of uart_rx.v
    wire rx_overrun_err_tirg_sysclk;  // From uart_rx of uart_rx.v
    wire rx_parity_err_trig_sysclk;  // From uart_rx of uart_rx.v
    wire tx_busy_aclk;  // From uart_sync_sysclk2aclk of uart_sync_sysclk2aclk.v
    wire tx_busy_sysclk;  // From uart_tx of uart_tx.v
    wire tx_fifo_almost_empty_aclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_almost_empty_sysclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_almost_full_aclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_almost_full_sysclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_empty_aclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_empty_sysclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_full_aclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_full_sysclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire [8:0] tx_fifo_rdata_sysclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_rdata_valid_sysclk;  // From uart_tx_fifo_async of uart_tx_fifo_async.v
    wire tx_fifo_ren_sysclk;  // From uart_tx of uart_tx.v
    wire [4:0] tx_fifo_th_level_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire [8:0] uart_data_aclk;  // From uart_axilite_slv of uart_axilite_slv.v, ...
    wire uart_data_rtrig_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire uart_data_wtrig_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire uart_enable_aclk;  // From uart_axilite_slv of uart_axilite_slv.v
    wire uart_enable_sysclk;  // From uart_sync_aclk2sysclk of uart_sync_aclk2sysclk.v
    wire uart_rtsn_sysclk;  // From uart_rx of uart_rx.v
    wire uart_txd_sysclk;  // From uart_tx of uart_tx.v
    // End of automatics

    //=========================================
    // AUTO_TEMPLATE definitions
    //=========================================
    /* uart_axilite_slv AUTO_TEMPLATE (
        .i_\(.*\)_\([a-z]+\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),
      
    ); */

    /* uart_sync_aclk2sysclk AUTO_TEMPLATE (
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),
            
    ); */

    /* uart_sync_sysclk2aclk AUTO_TEMPLATE (
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),
            
    ); */


    /* uart_tx_fifo_async AUTO_TEMPLATE (
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),
            
    ); */

    /* uart_rx_fifo_async AUTO_TEMPLATE (
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),
            
    ); */


    /* uart_clk_divider AUTO_TEMPLATE (
        .\(.*\)_fifo_\(.*\)\([a-z]+clk\)r? (tx_fifo_\2\3[]),
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),

    ); */

    /* uart_tx AUTO_TEMPLATE (
        .\(.*\)_fifo_\(.*\)\([a-z]+clk\)r? (tx_fifo_\2\3[]),
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),

    ); */

    /* uart_rx AUTO_TEMPLATE (
        .\(.*\)_fifo_\(.*\)\([a-z]+clk\)r? (rx_fifo_\2\3[]),
        .i_\(.*\)_\([a-z]+clk\) (\1_\2[]),
        .o_\(.*\)_\([a-z]+clk\)r? (\1_\2[]),

    ); */


    //=========================================
    // Instances
    //=========================================

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) uart_synchronizer_rxd (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_uart_rxd),
        .DATA_OUT(uart_rxd_sysclk)
    );
    uart_synchronizer #(
        .FF_DEPTH(2)
    ) uart_synchronizer_cts (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_uart_ctsn),
        .DATA_OUT(uart_ctsn_sysclk)
    );

    uart_axilite_slv #(
        .ADDR_BITWIDTH(ADDR_BITWIDTH),
        .DATA_BITWIDTH(DATA_BITWIDTH),
        .VARID_ADDR_BITWIDTH(VARID_ADDR_BITWIDTH)
    ) uart_axilite_slv (
        /*AUTOINST*/
        // Outputs
        .o_break_send_aclkr             (break_send_aclk),                    // Templated
        .o_uart_enable_aclkr            (uart_enable_aclk),                   // Templated
        .o_conf_data_bit_width_aclkr    (conf_data_bit_width_aclk[3:0]),      // Templated
        .o_conf_stop_bit_width_sel_aclkr(conf_stop_bit_width_sel_aclk[1:0]),  // Templated
        .o_conf_parity_bit_aclkr        (conf_parity_bit_aclk[1:0]),          // Templated
        .o_conf_tx_inv_aclkr            (conf_tx_inv_aclk),                   // Templated
        .o_conf_rx_inv_aclkr            (conf_rx_inv_aclk),                   // Templated
        .o_conf_hw_flow_en_aclkr        (conf_hw_flow_en_aclk),               // Templated
        .o_conf_samp_num_sel_aclkr      (conf_samp_num_sel_aclk),             // Templated
        .o_conf_over_samp_sel_aclkr     (conf_over_samp_sel_aclk[1:0]),       // Templated
        .o_conf_clk_div_aclkr           (conf_clk_div_aclk[15:0]),            // Templated
        .o_uart_data_aclkr              (uart_data_aclk[8:0]),                // Templated
        .o_uart_data_wtrig_aclkr        (uart_data_wtrig_aclk),               // Templated
        .o_uart_data_rtrig_aclkr        (uart_data_rtrig_aclk),               // Templated
        .o_int_break_det_en_aclkr       (int_break_det_en_aclk),              // Templated
        .o_int_parity_err_en_aclkr      (int_parity_err_en_aclk),             // Templated
        .o_int_framing_err_en_aclkr     (int_framing_err_en_aclk),            // Templated
        .o_int_rx_timeout_en_aclkr      (int_rx_timeout_en_aclk),             // Templated
        .o_int_overrun_err_en_aclkr     (int_overrun_err_en_aclk),            // Templated
        .o_int_tx_fifo_th_en_aclkr      (int_tx_fifo_th_en_aclk),             // Templated
        .o_int_rx_fifo_th_en_aclkr      (int_rx_fifo_th_en_aclk),             // Templated
        .o_rx_fifo_th_level_aclkr       (rx_fifo_th_level_aclk[4:0]),         // Templated
        .o_tx_fifo_th_level_aclkr       (tx_fifo_th_level_aclk[4:0]),         // Templated
        .o_interrupt_aclkr              (interrupt_aclk),                     // Templated
        .awready                        (awready),
        .wready                         (wready),
        .bresp                          (bresp[1:0]),
        .bvalid                         (bvalid),
        .arready                        (arready),
        .rdata                          (rdata[DATA_BITWIDTH-1:0]),
        .rresp                          (rresp[1:0]),
        .rvalid                         (rvalid),
        // Inputs
        .aclk                           (aclk),
        .aresetn                        (aresetn),
        .i_uart_data_aclk               (uart_data_aclk[8:0]),                // Templated
        .i_break_det_aclk               (break_det_aclk),                     // Templated
        .i_rx_busy_aclk                 (rx_busy_aclk),                       // Templated
        .i_tx_busy_aclk                 (tx_busy_aclk),                       // Templated
        .i_rx_fifo_full_aclk            (rx_fifo_full_aclk),                  // Templated
        .i_rx_fifo_empty_aclk           (rx_fifo_empty_aclk),                 // Templated
        .i_tx_fifo_full_aclk            (tx_fifo_full_aclk),                  // Templated
        .i_int_break_det_raw_set_aclk   (int_break_det_raw_set_aclk),         // Templated
        .i_int_parity_err_raw_set_aclk  (int_parity_err_raw_set_aclk),        // Templated
        .i_int_framing_err_raw_set_aclk (int_framing_err_raw_set_aclk),       // Templated
        .i_int_rx_timeout_raw_set_aclk  (int_rx_timeout_raw_set_aclk),        // Templated
        .i_int_overrun_err_raw_set_aclk (int_overrun_err_raw_set_aclk),       // Templated
        .i_int_tx_fifo_th_raw_set_aclk  (int_tx_fifo_th_raw_set_aclk),        // Templated
        .i_int_rx_fifo_th_raw_set_aclk  (int_rx_fifo_th_raw_set_aclk),        // Templated
        .awaddr                         (awaddr[ADDR_BITWIDTH-1:0]),
        .awprot                         (awprot),
        .awvalid                        (awvalid),
        .wdata                          (wdata[DATA_BITWIDTH-1:0]),
        .wstrb                          (wstrb[(ADDR_BITWIDTH/8)-1:0]),
        .wvalid                         (wvalid),
        .bready                         (bready),
        .araddr                         (araddr[ADDR_BITWIDTH-1:0]),
        .arprot                         (arprot),
        .arvalid                        (arvalid),
        .rready                         (rready)
    );

    uart_sync_aclk2sysclk uart_sync_aclk2sysclk (
        /*AUTOINST*/
        // Outputs
        .o_break_send_sysclkr             (break_send_sysclk),                    // Templated
        .o_uart_enable_sysclkr            (uart_enable_sysclk),                   // Templated
        .o_conf_data_bit_width_sysclkr    (conf_data_bit_width_sysclk[3:0]),      // Templated
        .o_conf_stop_bit_width_sel_sysclkr(conf_stop_bit_width_sel_sysclk[1:0]),  // Templated
        .o_conf_parity_bit_sysclkr        (conf_parity_bit_sysclk[1:0]),          // Templated
        .o_conf_tx_inv_sysclkr            (conf_tx_inv_sysclk),                   // Templated
        .o_conf_rx_inv_sysclkr            (conf_rx_inv_sysclk),                   // Templated
        .o_conf_hw_flow_en_sysclkr        (conf_hw_flow_en_sysclk),               // Templated
        .o_conf_samp_num_sel_sysclkr      (conf_samp_num_sel_sysclk),             // Templated
        .o_conf_over_samp_sel_sysclkr     (conf_over_samp_sel_sysclk[1:0]),       // Templated
        .o_conf_clk_div_sysclkr           (conf_clk_div_sysclk[15:0]),            // Templated
        // Inputs
        .sysclk                           (sysclk),
        .sysrst_n                         (sysrst_n),
        .i_break_send_aclk                (break_send_aclk),                      // Templated
        .i_uart_enable_aclk               (uart_enable_aclk),                     // Templated
        .i_conf_data_bit_width_aclk       (conf_data_bit_width_aclk[3:0]),        // Templated
        .i_conf_stop_bit_width_sel_aclk   (conf_stop_bit_width_sel_aclk[1:0]),    // Templated
        .i_conf_parity_bit_aclk           (conf_parity_bit_aclk[1:0]),            // Templated
        .i_conf_tx_inv_aclk               (conf_tx_inv_aclk),                     // Templated
        .i_conf_rx_inv_aclk               (conf_rx_inv_aclk),                     // Templated
        .i_conf_hw_flow_en_aclk           (conf_hw_flow_en_aclk),                 // Templated
        .i_conf_samp_num_sel_aclk         (conf_samp_num_sel_aclk),               // Templated
        .i_conf_over_samp_sel_aclk        (conf_over_samp_sel_aclk[1:0]),         // Templated
        .i_conf_clk_div_aclk              (conf_clk_div_aclk[15:0])
    );  // Templated

    uart_sync_sysclk2aclk uart_sync_sysclk2aclk (
        /*AUTOINST*/
        // Outputs
        .o_break_det_aclkr              (break_det_aclk),                 // Templated
        .o_rx_busy_aclkr                (rx_busy_aclk),                   // Templated
        .o_tx_busy_aclkr                (tx_busy_aclk),                   // Templated
        .o_int_break_det_raw_set_aclk   (int_break_det_raw_set_aclk),     // Templated
        .o_int_parity_err_raw_set_aclkr (int_parity_err_raw_set_aclk),    // Templated
        .o_int_framing_err_raw_se_aclkr (int_framing_err_raw_se_aclk),    // Templated
        .o_int_rx_timeout_raw_set_aclkr (int_rx_timeout_raw_set_aclk),    // Templated
        .o_int_overrun_err_raw_set_aclkr(int_overrun_err_raw_set_aclk),   // Templated
        // Inputs
        .aclk                           (aclk),
        .aresetn                        (aresetn),
        .sysclk                         (sysclk),
        .sysrst_n                       (sysrst_n),
        .i_tx_busy_sysclk               (tx_busy_sysclk),                 // Templated
        .i_rx_busy_sysclk               (rx_busy_sysclk),                 // Templated
        .i_rx_framing_err_trig_sysclk   (rx_framing_err_trig_sysclk),     // Templated
        .i_rx_parity_err_trig_sysclk    (rx_parity_err_trig_sysclk),      // Templated
        .i_rx_overrun_err_tirg_sysclk   (rx_overrun_err_tirg_sysclk),     // Templated
        .i_rx_detect_timeout_tirg_sysclk(rx_detect_timeout_tirg_sysclk),  // Templated
        .i_rx_detect_break_sysclk       (rx_detect_break_sysclk)
    );  // Templated

    uart_clk_divider uart_clk_divider (
        /*AUTOINST*/
        // Outputs
        .o_over_samp_clken_sysclkr(over_samp_clken_sysclk),    // Templated
        // Inputs
        .sysclk                   (sysclk),
        .sysrst_n                 (sysrst_n),
        .i_uart_enable_sysclk     (uart_enable_sysclk),        // Templated
        .i_conf_clk_div_sysclk    (conf_clk_div_sysclk[15:0])
    );  // Templated

    uart_tx_fifo_async #(
        .SYNC_FF_DEPTH(2),
        .ALMOST_FULL_SIZE(12),
        .ALMOST_EMPTY_SIZE(3)
    ) uart_tx_fifo_async (
        /*AUTOINST*/
        // Outputs
        .o_tx_fifo_rdata_sysclkr       (tx_fifo_rdata_sysclk[8:0]),    // Templated
        .o_tx_fifo_rdata_valid_sysclkr (tx_fifo_rdata_valid_sysclk),   // Templated
        .o_tx_fifo_empty_aclkr         (tx_fifo_empty_aclk),           // Templated
        .o_tx_fifo_full_aclkr          (tx_fifo_full_aclk),            // Templated
        .o_tx_fifo_almost_full_aclkr   (tx_fifo_almost_full_aclk),     // Templated
        .o_tx_fifo_almost_empty_aclkr  (tx_fifo_almost_empty_aclk),    // Templated
        .o_tx_fifo_empty_sysclkr       (tx_fifo_empty_sysclk),         // Templated
        .o_tx_fifo_full_sysclkr        (tx_fifo_full_sysclk),          // Templated
        .o_tx_fifo_almost_full_sysclkr (tx_fifo_almost_full_sysclk),   // Templated
        .o_tx_fifo_almost_empty_sysclkr(tx_fifo_almost_empty_sysclk),  // Templated
        .o_int_tx_fifo_th_raw_set_aclkr(int_tx_fifo_th_raw_set_aclk),  // Templated
        // Inputs
        .aclk                          (aclk),
        .sysclk                        (sysclk),
        .aresetn                       (aresetn),
        .sysrst_n                      (sysrst_n),
        .i_uart_data_wtrig_aclk        (uart_data_wtrig_aclk),         // Templated
        .i_uart_data_aclk              (uart_data_aclk[8:0]),          // Templated
        .i_tx_fifo_ren_sysclk          (tx_fifo_ren_sysclk),           // Templated
        .i_tx_fifo_th_level_aclk       (tx_fifo_th_level_aclk[4:0])
    );  // Templated

    uart_rx_fifo_async #(
        .SYNC_FF_DEPTH(2),
        .ALMOST_FULL_SIZE(12),
        .ALMOST_EMPTY_SIZE(3)
    ) uart_rx_fifo_async (
        /*AUTOINST*/
        // Outputs
        .o_uart_data_aclkr             (uart_data_aclk[8:0]),          // Templated
        .o_rx_fifo_empty_sysclkr       (rx_fifo_empty_sysclk),         // Templated
        .o_rx_fifo_full_sysclkr        (rx_fifo_full_sysclk),          // Templated
        .o_rx_fifo_almost_full_sysclkr (rx_fifo_almost_full_sysclk),   // Templated
        .o_rx_fifo_almost_empty_sysclkr(rx_fifo_almost_empty_sysclk),  // Templated
        .o_rx_fifo_empty_aclkr         (rx_fifo_empty_aclk),           // Templated
        .o_rx_fifo_full_aclkr          (rx_fifo_full_aclk),            // Templated
        .o_rx_fifo_almost_full_aclkr   (rx_fifo_almost_full_aclk),     // Templated
        .o_rx_fifo_almost_empty_aclkr  (rx_fifo_almost_empty_aclk),    // Templated
        .o_int_rx_fifo_th_raw_set_aclkr(int_rx_fifo_th_raw_set_aclk),  // Templated
        // Inputs
        .aclk                          (aclk),
        .sysclk                        (sysclk),
        .aresetn                       (aresetn),
        .sysrst_n                      (sysrst_n),
        .i_rx_fifo_wen_sysclk          (rx_fifo_wen_sysclk),           // Templated
        .i_rx_fifo_wdata_sysclk        (rx_fifo_wdata_sysclk[8:0]),    // Templated
        .i_uart_data_rtrig_aclk        (uart_data_rtrig_aclk),         // Templated
        .i_rx_fifo_th_level_aclk       (rx_fifo_th_level_aclk[4:0])
    );  // Templated

    uart_tx uart_tx (
        /*AUTOINST*/
        // Outputs
        .o_fifo_ren_sysclkr              (tx_fifo_ren_sysclk),                   // Templated
        .o_tx_busy_sysclkr               (tx_busy_sysclk),                       // Templated
        .o_uart_txd_sysclkr              (uart_txd_sysclk),                      // Templated
        // Inputs
        .sysclk                          (sysclk),
        .sysrst_n                        (sysrst_n),
        .i_break_send_sysclk             (break_send_sysclk),                    // Templated
        .i_uart_enable_sysclk            (uart_enable_sysclk),                   // Templated
        .i_conf_data_bit_width_sysclk    (conf_data_bit_width_sysclk[3:0]),      // Templated
        .i_conf_stop_bit_width_sel_sysclk(conf_stop_bit_width_sel_sysclk[1:0]),  // Templated
        .i_conf_parity_bit_sysclk        (conf_parity_bit_sysclk[1:0]),          // Templated
        .i_conf_tx_inv_sysclk            (conf_tx_inv_sysclk),                   // Templated
        .i_conf_hw_flow_en_sysclk        (conf_hw_flow_en_sysclk),               // Templated
        .i_conf_over_samp_sel_sysclk     (conf_over_samp_sel_sysclk[1:0]),       // Templated
        .i_over_samp_clken_sysclk        (over_samp_clken_sysclk),               // Templated
        .i_fifo_rdata_sysclk             (tx_fifo_rdata_sysclk[8:0]),            // Templated
        .i_fifo_rdata_valid_sysclk       (tx_fifo_rdata_valid_sysclk),           // Templated
        .i_fifo_empty_sysclk             (tx_fifo_empty_sysclk),                 // Templated
        .i_uart_ctsn_sysclk              (uart_ctsn_sysclk)
    );  // Templated

    uart_rx uart_rx (
        /*AUTOINST*/
        // Outputs
        .o_fifo_wen_sysclkr              (rx_fifo_wen_sysclk),                   // Templated
        .o_fifo_wdata_sysclkr            (rx_fifo_wdata_sysclk[8:0]),            // Templated
        .o_rx_busy_sysclkr               (rx_busy_sysclk),                       // Templated
        .o_rx_framing_err_trig_sysclkr   (rx_framing_err_trig_sysclk),           // Templated
        .o_rx_parity_err_trig_sysclkr    (rx_parity_err_trig_sysclk),            // Templated
        .o_rx_overrun_err_tirg_sysclkr   (rx_overrun_err_tirg_sysclk),           // Templated
        .o_rx_detect_timeout_tirg_sysclkr(rx_detect_timeout_tirg_sysclk),        // Templated
        .o_rx_detect_break_sysclkr       (rx_detect_break_sysclk),               // Templated
        .o_uart_rtsn_sysclk              (uart_rtsn_sysclk),                     // Templated
        // Inputs
        .sysclk                          (sysclk),
        .sysrst_n                        (sysrst_n),
        .i_uart_enable_sysclk            (uart_enable_sysclk),                   // Templated
        .i_conf_data_bit_width_sysclk    (conf_data_bit_width_sysclk[3:0]),      // Templated
        .i_conf_stop_bit_width_sel_sysclk(conf_stop_bit_width_sel_sysclk[1:0]),  // Templated
        .i_conf_parity_bit_sysclk        (conf_parity_bit_sysclk[1:0]),          // Templated
        .i_conf_rx_inv_sysclk            (conf_rx_inv_sysclk),                   // Templated
        .i_conf_hw_flow_en_sysclk        (conf_hw_flow_en_sysclk),               // Templated
        .i_conf_samp_num_sel_sysclk      (conf_samp_num_sel_sysclk),             // Templated
        .i_conf_over_samp_sel_sysclk     (conf_over_samp_sel_sysclk[1:0]),       // Templated
        .i_over_samp_clken_sysclk        (over_samp_clken_sysclk),               // Templated
        .i_fifo_empty_sysclk             (rx_fifo_empty_sysclk),                 // Templated
        .i_fifo_full_sysclk              (rx_fifo_full_sysclk),                  // Templated
        .i_fifo_almost_full_sysclk       (rx_fifo_almost_full_sysclk),           // Templated
        .i_uart_rxd_sysclk               (uart_rxd_sysclk)
    );  // Templated


endmodule

`default_nettype wire
// Local Variables:
// verilog-library-directories:("./")
// verilog-auto-inst-column:24  ;; Min. 24?
// indent-tabs-mode:nil
// End:
