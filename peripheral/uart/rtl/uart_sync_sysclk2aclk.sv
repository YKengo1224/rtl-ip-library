`default_nettype none
module uart_sync_sysclk2aclk (
    input wire aclk,
    input wire aresetn,
    input wire sysclk,
    input wire sysrst_n,

    // sysclk domain inputs
    input wire i_tx_busy_sysclk,
    input wire i_rx_busy_sysclk,
    input wire i_rx_framing_err_trig_sysclk,
    input wire i_rx_parity_err_trig_sysclk,
    input wire i_rx_overrun_err_tirg_sysclk,
    input wire i_rx_detect_timeout_tirg_sysclk,
    input wire i_rx_detect_break_sysclk,

    // aclk domain outputs
    output wire o_break_det_aclkr,
    output wire o_rx_busy_aclkr,
    output wire o_tx_busy_aclkr,
    output wire o_int_break_det_raw_set_aclk,
    output wire o_int_parity_err_raw_set_aclkr,
    output wire o_int_framing_err_raw_set_aclkr,
    output wire o_int_rx_timeout_raw_set_aclkr,
    output wire o_int_overrun_err_raw_set_aclkr
);

    //=========================================
    // Level Signals Synchronization (sysclk -> aclk)
    //=========================================
    wire tx_busy_sync_aclkr;
    wire rx_busy_sync_aclkr;
    wire break_det_sync_aclkr;

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_tx_busy (
        .CLK(aclk),
        .RST_N(aresetn),
        .DATA_IN(i_tx_busy_sysclk),
        .DATA_OUT(tx_busy_sync_aclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_rx_busy (
        .CLK(aclk),
        .RST_N(aresetn),
        .DATA_IN(i_rx_busy_sysclk),
        .DATA_OUT(rx_busy_sync_aclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_break_det (
        .CLK(aclk),
        .RST_N(aresetn),
        .DATA_IN(i_rx_detect_break_sysclk),
        .DATA_OUT(break_det_sync_aclkr)
    );

    assign o_tx_busy_aclkr   = tx_busy_sync_aclkr;
    assign o_rx_busy_aclkr   = rx_busy_sync_aclkr;
    assign o_break_det_aclkr = break_det_sync_aclkr;
    //=========================================
    // Pulse/Trigger Synchronization (sysclk -> aclk)
    // Using toggle synchronizer to prevent pulse loss
    //=========================================
    uart_pulse_synchronizer #(
        .FF_DEPTH(2)
    ) sync_framing_err (
        .src_clk(sysclk),
        .src_rst_n(sysrst_n),
        .src_pulse(i_rx_framing_err_trig_sysclk),
        .dest_clk(aclk),
        .dest_rst_n(aresetn),
        .dest_pulse(o_int_framing_err_raw_set_aclkr)
    );

    uart_pulse_synchronizer #(
        .FF_DEPTH(2)
    ) sync_parity_err (
        .src_clk(sysclk),
        .src_rst_n(sysrst_n),
        .src_pulse(i_rx_parity_err_trig_sysclk),
        .dest_clk(aclk),
        .dest_rst_n(aresetn),
        .dest_pulse(o_int_parity_err_raw_set_aclkr)
    );

    uart_pulse_synchronizer #(
        .FF_DEPTH(2)
    ) sync_overrun_err (
        .src_clk(sysclk),
        .src_rst_n(sysrst_n),
        .src_pulse(i_rx_overrun_err_tirg_sysclk),
        .dest_clk(aclk),
        .dest_rst_n(aresetn),
        .dest_pulse(o_int_overrun_err_raw_set_aclkr)
    );

    uart_pulse_synchronizer #(
        .FF_DEPTH(2)
    ) sync_timeout (
        .src_clk(sysclk),
        .src_rst_n(sysrst_n),
        .src_pulse(i_rx_detect_timeout_tirg_sysclk),
        .dest_clk(aclk),
        .dest_rst_n(aresetn),
        .dest_pulse(o_int_rx_timeout_raw_set_aclkr)
    );


    reg break_det_sync_prev_aclkr;
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            break_det_sync_prev_aclkr <= 1'b0;
        end else begin
            break_det_sync_prev_aclkr <= break_det_sync_aclkr;
        end
    end

    assign o_int_break_det_raw_set_aclk = break_det_sync_aclkr && !break_det_sync_prev_aclkr;



endmodule
`default_nettype wire
