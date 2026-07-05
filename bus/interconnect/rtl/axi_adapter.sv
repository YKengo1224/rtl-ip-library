`default_nettype none

module axi_master_adapter #(
    parameter bit USE_FIFO = 0,
    parameter bit USE_SKID_BUFF = 1
) (
    axi_if.master axi_m_in_if,
    axi_if.master axi_m_out_if
);


    generate
        if (USE_FIFO) begin : BLK_GEN_FIFO_ASYNC
            fifo_async #(
                .BITWIDTH(32),
                .FIFO_SIZE(4),
                .SYNC_FF_DEPTH(2),
                .ALMOST_FULL_SIZE(3),
                .LA_MOST_EMPTY_SIZE(1)
            ) fifo_async_w (
                .WCLK(axi_m_in_if.aclk),
                .RCLK(axi_m_out_if.aclk),
                .RST_N_WCLK(axi_m_in_if.aresetn),
                .RST_N_RCLK(axi_m_out_if.aresetn),
                .W_EN_WCLK(axi_m_in_if.wvalid && axi_m_in_if.wready),
                .DATA_IN_WCLK(axi_m_in_if.wdata),
                .R_EN_RCLK(axi_m_out_if.wvalid && axi_m_out_if.wready),
                .DATA_OUT_RCLKR(axi_m_out_if.wdata),
                .DATA_OUT_VALID_RCLKR(axi_m_out_if.wvalid),

                .EMPTY_WCLKR,
                .FULL_WCLKR,
                .ALMOST_FULL_WCLKR,
                .ALMOST_EMPTY_WCLKR,
                .FIFO_AVAILABLE_WCLKR,

                .EMPTY_RCLKR,
                .FULL_RCLKR,
                .ALMOST_FULL_RCLKR,
                .ALMOST_EMPTY_RCLKR,
                .FIFO_AVAILABLE_RCLKR
            );


        end
    endgenerate


endmodule

`default_nettype wire
