`default_nettype none
module uart_tx (
    input wire       sysclk,
    input wire       sysrst_n,
    //config
    input wire       i_uart_enable_sysclk,
    input wire [3:0] i_conf_data_bit_width_aclkr_sysclk,
    input wire [1:0] i_conf_stop_bit_width_sel_aclk_sysclk,

    input reg [ 1:0] i_conf_parity_bit_sysclk,
    input reg        i_conf_tx_env_sysclk,
    input reg        i_conf_rx_env_sysclk,
    input reg        i_conf_hw_flow_en_sysclk,
    input reg        i_conf__samp_num_sel_sysclk,
    input reg [ 1:0] i_conf_over_samp_sel_sysclk,
    input reg [15:0] i_conf_clk_div_sysclk,
    input reg        i_break_send_sysclk


);
endmodule

`default_nettype wire
