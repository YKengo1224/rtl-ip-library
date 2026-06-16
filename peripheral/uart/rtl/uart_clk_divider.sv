`default_nettype none
module uart_clk_divider (
    input  wire        sysclk,
    input  wire        sysrst_n,
    input  wire        i_uart_enable_sysclk,
    input  wire [15:0] i_conf_clk_div_sysclk,
    output reg         o_over_samp_clken_sysclkr
);

    reg [15:0] divide_cnt_sysclkr;


    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            divide_cnt_sysclkr <= '0;
            o_over_samp_clken_sysclkr <= 1'b0;
        end else if (i_uart_enable_sysclk) begin
            if (i_conf_clk_div_sysclk > 16'd0) begin
                if (divide_cnt_sysclkr >= (i_conf_clk_div_sysclk - 16'd1)) begin
                    divide_cnt_sysclkr <= '0;
                    o_over_samp_clken_sysclkr <= 1'b1;
                end else begin
                    divide_cnt_sysclkr <= divide_cnt_sysclkr + 16'd1;
                    o_over_samp_clken_sysclkr <= 1'b0;
                end
            end else begin
                divide_cnt_sysclkr <= '0;
                o_over_samp_clken_sysclkr <= 1'b0;
            end
        end else begin
            divide_cnt_sysclkr <= '0;
            o_over_samp_clken_sysclkr <= 1'b0;
        end
    end

endmodule
`default_nettype wire
