`default_nettype none
module uart_sync_aclk2sysclk (
    input  wire        sysclk,
    input  wire        sysrst_n,
    // aclk domain inputs
    input  wire        i_break_send_aclk,
    input  wire        i_uart_enable_aclk,
    input  wire [ 3:0] i_conf_data_bit_width_aclk,
    input  wire [ 1:0] i_conf_stop_bit_width_sel_aclk,
    input  wire [ 1:0] i_conf_parity_bit_aclk,
    input  wire        i_conf_tx_inv_aclk,
    input  wire        i_conf_rx_inv_aclk,
    input  wire        i_conf_hw_flow_en_aclk,
    input  wire        i_conf_samp_num_sel_aclk,
    input  wire [ 1:0] i_conf_over_samp_sel_aclk,
    input  wire [15:0] i_conf_clk_div_aclk,
    // sysclk domain outputs
    output wire        o_break_send_sysclkr,
    output wire        o_uart_enable_sysclkr,
    output wire [ 3:0] o_conf_data_bit_width_sysclkr,
    output wire [ 1:0] o_conf_stop_bit_width_sel_sysclkr,
    output wire [ 1:0] o_conf_parity_bit_sysclkr,
    output wire        o_conf_tx_inv_sysclkr,
    output wire        o_conf_rx_inv_sysclkr,
    output wire        o_conf_hw_flow_en_sysclkr,
    output wire        o_conf_samp_num_sel_sysclkr,
    output wire [ 1:0] o_conf_over_samp_sel_sysclkr,
    output wire [15:0] o_conf_clk_div_sysclkr
);

    //=========================================
    // 1-bit Signals
    //=========================================
    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_break_send (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_break_send_aclk),
        .DATA_OUT(o_break_send_sysclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_uart_enable (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_uart_enable_aclk),
        .DATA_OUT(o_uart_enable_sysclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_tx_inv (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_conf_tx_inv_aclk),
        .DATA_OUT(o_conf_tx_inv_sysclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_rx_inv (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_conf_rx_inv_aclk),
        .DATA_OUT(o_conf_rx_inv_sysclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_hw_flow (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_conf_hw_flow_en_aclk),
        .DATA_OUT(o_conf_hw_flow_en_sysclkr)
    );

    uart_synchronizer #(
        .FF_DEPTH(2)
    ) sync_samp_num (
        .CLK(sysclk),
        .RST_N(sysrst_n),
        .DATA_IN(i_conf_samp_num_sel_aclk),
        .DATA_OUT(o_conf_samp_num_sel_sysclkr)
    );

    //=========================================
    // Multi-bit Signals (Using generate block)
    //=========================================
    genvar i;
    generate
        // conf_data_bit_width (4-bit)
        for (i = 0; i < 4; i++) begin : gen_sync_data_bit_width
            uart_synchronizer #(
                .FF_DEPTH(2)
            ) sync_inst (
                .CLK(sysclk),
                .RST_N(sysrst_n),
                .DATA_IN(i_conf_data_bit_width_aclk[i]),
                .DATA_OUT(o_conf_data_bit_width_sysclkr[i])
            );
        end

        // conf_stop_bit_width_sel (2-bit)
        for (i = 0; i < 2; i++) begin : gen_sync_stop_bit_width
            uart_synchronizer #(
                .FF_DEPTH(2)
            ) sync_inst (
                .CLK(sysclk),
                .RST_N(sysrst_n),
                .DATA_IN(i_conf_stop_bit_width_sel_aclk[i]),
                .DATA_OUT(o_conf_stop_bit_width_sel_sysclkr[i])
            );
        end

        // conf_parity_bit (2-bit)
        for (i = 0; i < 2; i++) begin : gen_sync_parity_bit
            uart_synchronizer #(
                .FF_DEPTH(2)
            ) sync_inst (
                .CLK(sysclk),
                .RST_N(sysrst_n),
                .DATA_IN(i_conf_parity_bit_aclk[i]),
                .DATA_OUT(o_conf_parity_bit_sysclkr[i])
            );
        end

        // conf_over_samp_sel (2-bit)
        for (i = 0; i < 2; i++) begin : gen_sync_over_samp
            uart_synchronizer #(
                .FF_DEPTH(2)
            ) sync_inst (
                .CLK(sysclk),
                .RST_N(sysrst_n),
                .DATA_IN(i_conf_over_samp_sel_aclk[i]),
                .DATA_OUT(o_conf_over_samp_sel_sysclkr[i])
            );
        end

        // conf_clk_div (16-bit)
        for (i = 0; i < 16; i++) begin : gen_sync_clk_div
            uart_synchronizer #(
                .FF_DEPTH(2)
            ) sync_inst (
                .CLK(sysclk),
                .RST_N(sysrst_n),
                .DATA_IN(i_conf_clk_div_aclk[i]),
                .DATA_OUT(o_conf_clk_div_sysclkr[i])
            );
        end
    endgenerate

endmodule
`default_nettype wire
